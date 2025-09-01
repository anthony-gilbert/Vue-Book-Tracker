# ArgoCD Setup and Maintenance

This directory contains the configuration and scripts for ArgoCD deployment on the book tracker infrastructure.

## Files Overview

- `values-argo.yaml` - Helm values for ArgoCD with optimized resource limits
- `verify-prerequisites.sh` - Verification script that checks and installs prerequisites (including kubectl)
- `setup-system.sh` - System preparation script for resource management
- `update-nginx.sh` - Script to update nginx proxy configuration 
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

1. **kubectl not found**: The verification script automatically installs kubectl if missing
2. **Resource Constraints**: Ensure server has at least 1GB available memory
3. **Disk Space**: Keep disk usage below 85%
4. **Service IP Changes**: Service IPs are stable, but if they change, run `update-nginx.sh`
5. **CI/CD Pipeline Failures**: Check if kubectl is available and cluster is accessible

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
1. Installs kubectl and verifies prerequisites (`verify-prerequisites.sh`)
2. Prepares deployment scripts (validates CI/CD environment)
3. Syncs applications via ArgoCD CLI

**Note**: System preparation and nginx configuration scripts are designed to:
- **Run fully** in production environments (on target servers)
- **Exit early** in CI/CD environments (GitHub Actions)

This separation ensures reliable deployments without manual intervention while avoiding CI/CD failures due to missing infrastructure components.

## Monitoring

Check ArgoCD health:
- Web UI: https://argocd.booktracker.dev
- CLI: `argocd app list`
- Kubernetes: `kubectl get pods -n argocd`
