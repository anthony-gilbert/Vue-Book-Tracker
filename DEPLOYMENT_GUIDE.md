# Deployment Guide - Fixing Bad Gateway Issues

This guide contains the permanent fix for the "Bad Gateway" error on booktracker.dev.

## Root Cause Analysis

The bad gateway error was caused by several misconfigurations:

1. **Nginx proxy configuration**: Pointing to wrong port/service
2. **SSL certificate mismatch**: Using anthonygilbert.dev cert for booktracker.dev  
3. **CORS configuration**: Backend not allowing production domain
4. **Service configuration**: Using ClusterIP instead of NodePort or proper ingress

## Permanent Fix Implementation

### 1. SSL Certificate Setup

First, obtain the correct SSL certificate for booktracker.dev:

```bash
# Run the SSL setup script
./setup-ssl-certificate.sh
```

### 2. Deploy Updated Configurations

Apply the updated Kubernetes configurations:

```bash
# Apply updated service configuration (NodePort)
kubectl apply -f kube-configs/service.yaml

# Apply updated ingress configuration
kubectl apply -f kube-configs/ingress.yaml

# Apply updated deployment (with CORS fix)
kubectl apply -f kube-configs/deployment.yaml
```

### 3. Update Nginx Configuration

Copy the updated nginx configuration:

```bash
# Copy the updated nginx config
sudo cp nginx-config/booktracker.dev /etc/nginx/sites-available/
sudo ln -sf /etc/nginx/sites-available/booktracker.dev /etc/nginx/sites-enabled/

# Test nginx configuration
sudo nginx -t

# Reload nginx
sudo systemctl reload nginx
```

### 4. Rebuild and Deploy Backend

The backend needs to be rebuilt with the updated CORS configuration:

```bash
# Build and push new backend image
cd backend
docker build -t anthonygilbertt/vue-book-tracker-backend:v2 .
docker push anthonygilbertt/vue-book-tracker-backend:v2

# Update deployment to use new image
kubectl set image deployment/book-tracker-backend backend=anthonygilbertt/vue-book-tracker-backend:v2 -n book-tracker
```

## Configuration Changes Made

### Backend CORS Configuration
- Added `https://booktracker.dev` and `http://booktracker.dev` to allowed origins
- Enabled credentials support

### Nginx Configuration
- Fixed SSL certificate paths to use booktracker.dev certificates
- Updated proxy pass to correct port (30080)
- Added proper API routing with `/api/` and `/health` endpoints
- Added CORS headers for preflight requests

### Kubernetes Services
- Changed from ClusterIP to NodePort
- Added explicit NodePort assignments (30080 for frontend, 30081 for backend)

### Kubernetes Ingress
- Changed ingress class from traefik to nginx
- Added explicit health check endpoint routing
- Fixed API path routing

## Verification Steps

1. Check SSL certificate is valid:
   ```bash
   openssl s_client -connect booktracker.dev:443 -servername booktracker.dev
   ```

2. Test health endpoint:
   ```bash
   curl -k https://booktracker.dev/health
   ```

3. Test API endpoint:
   ```bash
   curl -k https://booktracker.dev/api/v1/auth/login
   ```

4. Check Kubernetes pod status:
   ```bash
   kubectl get pods -n book-tracker
   kubectl logs -f deployment/book-tracker-backend -n book-tracker
   kubectl logs -f deployment/book-tracker-frontend -n book-tracker
   ```

## Monitoring and Maintenance

- Monitor nginx error logs: `tail -f /var/log/nginx/error.log`
- Monitor application logs: `kubectl logs -f -l app=book-tracker-backend -n book-tracker`
- Set up SSL certificate auto-renewal: `sudo crontab -e` and add:
  ```
  0 12 * * * /usr/bin/certbot renew --quiet --reload-hook "systemctl reload nginx"
  ```

## Rollback Plan

If issues occur, you can quickly rollback:

```bash
# Restore original nginx config
sudo cp nginx-config/booktracker.dev.backup /etc/nginx/sites-available/booktracker.dev
sudo systemctl reload nginx

# Rollback Kubernetes deployments
kubectl rollout undo deployment/book-tracker-backend -n book-tracker
kubectl rollout undo deployment/book-tracker-frontend -n book-tracker
```
