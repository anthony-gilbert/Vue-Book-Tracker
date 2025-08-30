# ArgoCD Domain Fix Documentation

## Issue Summary
The ArgoCD installation at `https://argocd.booktracker.dev` was not accessible due to several configuration and networking issues.

## Root Causes

### 1. DNS Configuration Missing
- **Problem**: No DNS A record existed for `argocd.booktracker.dev`
- **Solution**: Added DNS A record pointing to server IP `143.198.49.14`

### 2. Missing SSL Certificate Setup
- **Problem**: No Let's Encrypt certificate issuer was configured
- **Solution**: Created ClusterIssuer and Certificate resources for automatic SSL certificate management

### 3. LoadBalancer Service Issue
- **Problem**: Traefik LoadBalancer service was stuck in "pending" state (no external load balancer provider)
- **Solution**: Changed to NodePort service and configured nginx reverse proxy

### 4. Network Routing Issues
- **Problem**: ArgoCD was only accessible via internal cluster IPs
- **Solution**: Set up nginx reverse proxy to route external traffic to ArgoCD pods

### 5. Redirect Loop
- **Problem**: ArgoCD server was redirecting HTTP to HTTPS, causing redirect loops through nginx
- **Solution**: Configured ArgoCD in insecure mode behind nginx SSL termination

## Detailed Fix Steps

### 1. DNS Setup
```bash
# Added DNS A record (done via domain provider):
# Type: A
# Name: argocd.booktracker.dev  
# Value: 143.198.49.14
```

### 2. SSL Certificate Configuration
Created Let's Encrypt ClusterIssuer:
```yaml
# cluster-issuer.yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: admin@booktracker.dev
    privateKeySecretRef:
      name: letsencrypt-prod-key
    solvers:
    - http01:
        ingress:
          class: traefik
```

Created SSL Certificate:
```yaml
# certificate.yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: argocd-server-tls
  namespace: argocd
spec:
  secretName: argocd-server-tls
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  dnsNames:
    - argocd.booktracker.dev
```

### 3. Load Balancer Fix
```bash
# Changed Traefik service from LoadBalancer to NodePort
kubectl patch svc traefik -n kube-system -p '{"spec":{"type":"NodePort"}}'
```

### 4. Nginx Reverse Proxy Setup
Created nginx configuration at `/etc/nginx/sites-available/argocd-proxy`:
```nginx
server {
    listen 80;
    server_name argocd.booktracker.dev;
    
    # Handle Let's Encrypt challenges
    location /.well-known/acme-challenge/ {
        proxy_pass http://[CHALLENGE_POD_IP]:8089;
        proxy_set_header Host $host;
    }
    
    # Redirect all other HTTP to HTTPS
    location / {
        return 301 https://$server_name$request_uri;
    }
}

server {
    listen 443 ssl;
    server_name argocd.booktracker.dev;
    
    ssl_certificate /etc/ssl/certs/ssl-cert-snakeoil.pem;
    ssl_certificate_key /etc/ssl/private/ssl-cert-snakeoil.key;
    
    location / {
        proxy_pass http://[ARGOCD_POD_IP]:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_redirect off;
    }
}
```

### 5. ArgoCD Configuration
```bash
# Configure ArgoCD to run in insecure mode behind nginx SSL termination
kubectl patch configmap argocd-cmd-params-cm -n argocd --type merge -p '{"data":{"server.insecure":"true"}}'

# Set the proper external URL
kubectl patch configmap argocd-cm -n argocd --type merge -p '{"data":{"url":"https://argocd.booktracker.dev"}}'
```

## Commands Used

```bash
# Apply SSL configuration
kubectl apply -f cluster-issuer.yaml
kubectl apply -f certificate.yaml

# Fix LoadBalancer
kubectl patch svc traefik -n kube-system -p '{"spec":{"type":"NodePort"}}'

# Configure ArgoCD for reverse proxy
kubectl patch configmap argocd-cmd-params-cm -n argocd --type merge -p '{"data":{"server.insecure":"true"}}'

# Restart ArgoCD server
kubectl rollout restart deployment argocd-server -n argocd

# Install and configure nginx
apt-get install -y ssl-cert
# Create nginx config file
# Enable site and restart nginx
```

## Current Status
- ✅ **DNS**: argocd.booktracker.dev resolves to 143.198.49.14
- ✅ **SSL**: Self-signed certificate working, Let's Encrypt certificate configured
- ✅ **ArgoCD**: Accessible at https://argocd.booktracker.dev
- ✅ **Authentication**: Default admin credentials available

## Accessing ArgoCD
- **URL**: https://argocd.booktracker.dev
- **Username**: admin
- **Password**: Get with `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`

## Notes
- The setup uses nginx as a reverse proxy because the Kubernetes cluster doesn't have an external load balancer provider
- ArgoCD runs in insecure mode behind nginx SSL termination
- Pod IPs may change if pods restart - nginx config needs manual updates
- Let's Encrypt certificate will auto-renew via cert-manager
