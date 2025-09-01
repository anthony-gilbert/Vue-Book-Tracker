# ArgoCD Deployment Guide - Fixing argocd.booktracker.dev

This guide contains the permanent fix for ArgoCD accessibility issues on argocd.booktracker.dev.

## Root Cause Analysis

The ArgoCD subdomain was not working due to several issues:

1. **SSL certificate missing**: No proper SSL certificate for argocd.booktracker.dev
2. **Hardcoded IP addresses**: Nginx configuration using hardcoded pod IPs that change
3. **Service type mismatch**: Using ClusterIP instead of NodePort for external access
4. **Ingress misconfiguration**: Traefik ingress not working properly
5. **Pod deployment issues**: ArgoCD pods in error/pending states

## Permanent Fix Implementation

### 1. SSL Certificate Setup

Run the SSL setup script for the ArgoCD subdomain:

```bash
# Run the ArgoCD SSL setup script
./setup-argocd-ssl.sh
```

### 2. Update ArgoCD Service Configuration

The updated values file changes the ArgoCD server service to NodePort:

```yaml
server:
  service:
    type: NodePort
    nodePortHttp: 30081
    nodePortHttps: 30082
  ingress:
    enabled: false
```

### 3. Deploy Updated ArgoCD Configuration

```bash
# Apply updated ArgoCD configuration
helm upgrade argocd argo/argo-cd \
  --namespace argocd \
  --values helm-charts/argocd/values-argo.yaml \
  --version 5.51.6

# Wait for ArgoCD pods to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s
```

### 4. Update Nginx Configuration

```bash
# Copy the updated ArgoCD nginx config
sudo cp nginx-config/argocd.booktracker.dev /etc/nginx/sites-available/
sudo ln -sf /etc/nginx/sites-available/argocd.booktracker.dev /etc/nginx/sites-enabled/

# Remove old config if it exists
sudo rm -f /etc/nginx/sites-enabled/argocd-proxy

# Test nginx configuration
sudo nginx -t

# Reload nginx
sudo systemctl reload nginx
```

### 5. Configure ArgoCD for Reverse Proxy

```bash
# Configure ArgoCD to run in insecure mode behind nginx SSL termination
kubectl patch configmap argocd-cmd-params-cm -n argocd --type merge -p '{"data":{"server.insecure":"true"}}'

# Set the proper external URL
kubectl patch configmap argocd-cm -n argocd --type merge -p '{"data":{"url":"https://argocd.booktracker.dev"}}'

# Restart ArgoCD server to apply changes
kubectl rollout restart deployment argocd-server -n argocd
```

## Configuration Changes Made

### Nginx Configuration
- Updated SSL certificate paths to use argocd.booktracker.dev certificates
- Changed proxy target to use NodePort (30081) instead of hardcoded IPs
- Added WebSocket support for ArgoCD notifications
- Added GRPC support for ArgoCD API
- Increased timeouts for ArgoCD operations

### ArgoCD Helm Values
- Changed server service type from ClusterIP to NodePort
- Disabled Traefik ingress in favor of nginx reverse proxy
- Set specific NodePort values (30081 for HTTP, 30082 for HTTPS)
- Configured insecure mode for reverse proxy setup

## Verification Steps

1. **Check ArgoCD pods are running:**
   ```bash
   kubectl get pods -n argocd
   kubectl logs -f deployment/argocd-server -n argocd
   ```

2. **Verify SSL certificate:**
   ```bash
   openssl s_client -connect argocd.booktracker.dev:443 -servername argocd.booktracker.dev
   ```

3. **Test ArgoCD UI access:**
   ```bash
   curl -k https://argocd.booktracker.dev
   ```

4. **Get ArgoCD admin password:**
   ```bash
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
   ```

## Accessing ArgoCD

- **URL**: https://argocd.booktracker.dev
- **Username**: admin  
- **Password**: Run the command above to get the initial admin password

## Troubleshooting

### If ArgoCD pods are stuck in pending/error state:

```bash
# Check node resources
kubectl describe node

# Check pod events
kubectl describe pod -n argocd -l app.kubernetes.io/name=argocd-server

# Restart the deployment
kubectl rollout restart deployment argocd-server -n argocd
```

### If nginx returns 502 Bad Gateway:

```bash
# Check if ArgoCD service is accessible
kubectl port-forward svc/argocd-server -n argocd 8080:80

# Check nginx error logs
sudo tail -f /var/log/nginx/error.log

# Verify NodePort is accessible
curl http://127.0.0.1:30081
```

### If SSL certificate issues:

```bash
# Check certificate status
sudo certbot certificates

# Renew certificate if needed
sudo certbot renew

# Restart nginx
sudo systemctl restart nginx
```

## Monitoring and Maintenance

- Monitor ArgoCD application logs: `kubectl logs -f -l app.kubernetes.io/name=argocd-server -n argocd`
- Monitor nginx error logs: `tail -f /var/log/nginx/error.log`
- Set up SSL certificate auto-renewal in crontab
- Monitor ArgoCD resource usage: `kubectl top pods -n argocd`

## Rollback Plan

If issues occur, you can quickly rollback:

```bash
# Rollback ArgoCD deployment
helm rollback argocd -n argocd

# Restore old nginx config if needed
sudo cp nginx-config/argocd-proxy.template /etc/nginx/sites-available/argocd-proxy
sudo systemctl reload nginx
```

## Security Notes

- ArgoCD runs in insecure mode behind nginx SSL termination
- SSL certificates are managed by Let's Encrypt with auto-renewal
- Access is restricted to the configured domain only
- Consider implementing additional authentication/authorization if needed
