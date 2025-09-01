# ArgoCD Setup and Maintenance

This directory contains the configuration and scripts for ArgoCD deployment on the book tracker infrastructure.

## Files Overview

- `values-argo.yaml` - Helm values for ArgoCD with optimized resource limits
- `update-nginx.sh` - Script to update nginx proxy configuration 
- `setup-system.sh` - System preparation script for resource management
- `../nginx-config/argocd-proxy.template` - Nginx configuration template

## Resource Configuration

The ArgoCD deployment is configured with the following resource limits to prevent 502 errors:

```yaml
server:
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 200m
      memory: 256Mi

repoServer:
  resources:
    limits:
      cpu: 300m
      memory: 512Mi
    requests:
      cpu: 150m
      memory: 256Mi
```

## Architecture

The deployment uses a hybrid approach:
1. **Kubernetes Ingress**: Traefik handles internal routing
2. **Nginx Proxy**: Host-level nginx proxies to Kubernetes services for SSL termination
3. **Service IPs**: Uses stable Kubernetes service IPs instead of pod IPs

## Troubleshooting

### 502 Bad Gateway Errors

If you encounter 502 errors after deployment:

1. **Check ArgoCD pods**:
   ```bash
   kubectl get pods -n argocd
   ```

2. **Run the nginx update script**:
   ```bash
   sudo ./update-nginx.sh
   ```

3. **Check system resources**:
   ```bash
   free -h
   df -h
   ```

### Common Issues

1. **Resource Constraints**: Ensure server has at least 1GB available memory
2. **Disk Space**: Keep disk usage below 85%
3. **Service IP Changes**: Service IPs are stable, but if they change, run `update-nginx.sh`

### Manual Recovery

If ArgoCD is completely down:

```bash
# 1. Prepare system
sudo ./setup-system.sh

# 2. Update nginx configuration
sudo ./update-nginx.sh

# 3. Restart ArgoCD deployment if needed
kubectl rollout restart deployment argocd-server -n argocd
```

## CI/CD Integration

The GitHub Actions pipeline automatically:
1. Prepares system resources (`setup-system.sh`)
2. Updates nginx proxy configuration (`update-nginx.sh`)
3. Syncs applications via ArgoCD CLI

This ensures reliable deployments without manual intervention.

## Monitoring

Check ArgoCD health:
- Web UI: https://argocd.booktracker.dev
- CLI: `argocd app list`
- Kubernetes: `kubectl get pods -n argocd`
