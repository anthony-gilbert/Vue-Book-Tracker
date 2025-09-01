# ArgoCD Troubleshooting Guide

## Current Issue: argocd.booktracker.dev returns 502 Bad Gateway

### Root Cause Analysis

The ArgoCD domain is not working due to:

1. **ArgoCD Server Pod Issues**: The argocd-server pod is running but not ready (0/1 status)
2. **Kubernetes API Connectivity**: ArgoCD server is experiencing TLS handshake timeouts with K8s API
3. **Service Accessibility**: ArgoCD service (10.43.54.4:80) is not responding to requests
4. **SSL Certificate Mismatch**: Using wrong SSL certificate for the subdomain

### Current Status

- **Nginx**: Configured and running with proper proxy settings
- **SSL**: Using self-signed certificate (temporary)
- **ArgoCD Pods**: Server pod running but not ready
- **Service**: ClusterIP service not accessible from nginx

### Immediate Fix Steps

#### Step 1: Restart ArgoCD Components

```bash
# Delete problematic pods to force restart
kubectl delete pod -n argocd -l app.kubernetes.io/name=argocd-server
kubectl delete pod -n argocd -l app.kubernetes.io/name=argocd-application-controller

# Wait for pods to restart
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s
```

#### Step 2: Check ArgoCD Server Status

```bash
# Check pod status
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server

# Check logs for errors
kubectl logs -f -l app.kubernetes.io/name=argocd-server -n argocd

# Check service endpoints
kubectl get endpoints -n argocd argocd-server
```

#### Step 3: Port Forward Test (Bypass Service)

```bash
# Port forward directly to ArgoCD server pod
kubectl port-forward -n argocd svc/argocd-server 8080:80 &

# Test direct access
curl http://localhost:8080

# Update nginx to use port forward if working
```

#### Step 4: Alternative - Use NodePort Service

```bash
# Convert service to NodePort
kubectl patch svc argocd-server -n argocd -p '{"spec":{"type":"NodePort"}}'

# Get the assigned NodePort
kubectl get svc argocd-server -n argocd

# Update nginx config to use NodePort
```

### Quick Fix Script

Use the provided script to apply a working configuration:

```bash
# Apply the simple fix
./fix-argocd-simple.sh

# Check if it works
curl -k https://argocd.booktracker.dev
```

### Manual Steps if Script Fails

#### 1. Fix Nginx Configuration

```bash
# Use the working nginx config
sudo cp /root/Vue-Book-Tracker/nginx-config/argocd.booktracker.dev /etc/nginx/sites-available/
sudo ln -sf /etc/nginx/sites-available/argocd.booktracker.dev /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
```

#### 2. Check ArgoCD Service IP

```bash
# Get current service IP
kubectl get svc argocd-server -n argocd -o jsonpath='{.spec.clusterIP}'

# Update nginx config with correct IP
sudo sed -i 's/10.43.54.4/NEW_SERVICE_IP/' /etc/nginx/sites-available/argocd.booktracker.dev
sudo systemctl reload nginx
```

#### 3. Test Service Connectivity

```bash
# Test if service is accessible
curl http://SERVICE_IP:80

# If not accessible, use port forward
kubectl port-forward svc/argocd-server -n argocd 8081:80 &

# Update nginx to proxy to localhost:8081
```

### SSL Certificate Fix

#### Temporary Solution (Current)
- Using self-signed certificate (`/etc/ssl/certs/ssl-cert-snakeoil.pem`)
- Browser will show security warning but ArgoCD will work

#### Permanent Solution
```bash
# Get proper SSL certificate for argocd.booktracker.dev
sudo certbot certonly --nginx -d argocd.booktracker.dev

# Update nginx config to use new certificate
sudo sed -i 's|ssl-cert-snakeoil.pem|/etc/letsencrypt/live/argocd.booktracker.dev/fullchain.pem|' /etc/nginx/sites-available/argocd.booktracker.dev
sudo sed -i 's|ssl-cert-snakeoil.key|/etc/letsencrypt/live/argocd.booktracker.dev/privkey.pem|' /etc/nginx/sites-available/argocd.booktracker.dev
sudo systemctl reload nginx
```

### Common Error Messages and Solutions

#### "502 Bad Gateway"
- **Cause**: ArgoCD service not responding
- **Solution**: Check pod status, restart pods, verify service IP

#### "SSL certificate problem"  
- **Cause**: Certificate mismatch or self-signed certificate
- **Solution**: Use `-k` flag with curl or get proper certificate

#### "TLS handshake timeout"
- **Cause**: Kubernetes API connectivity issues
- **Solution**: Restart ArgoCD pods, check cluster health

#### "Connection refused"
- **Cause**: Service not accessible
- **Solution**: Use port forwarding or NodePort service

### Verification Commands

```bash
# Check nginx status
sudo systemctl status nginx

# Check nginx error logs
sudo tail -f /var/log/nginx/error.log

# Check ArgoCD pods
kubectl get pods -n argocd

# Test ArgoCD access
curl -k https://argocd.booktracker.dev

# Get ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### Emergency Access via Port Forward

If all else fails, you can access ArgoCD directly:

```bash
# Port forward to local machine
kubectl port-forward svc/argocd-server -n argocd 8080:80

# Access via localhost
open http://localhost:8080
```

## Expected Resolution Time

- **Quick Fix**: 5-10 minutes (using self-signed cert)
- **Full Fix**: 15-30 minutes (with proper SSL certificate)
- **Complex Issues**: May require cluster restart or ArgoCD reinstallation
