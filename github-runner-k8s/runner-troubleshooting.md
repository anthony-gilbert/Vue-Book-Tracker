# GitHub Runner Troubleshooting Guide

## Common Issues and Fixes

### 1. Runner Crashes Immediately
**Symptoms:** Pod starts then crashes in a loop
**Causes:** 
- Expired or invalid runner token
- Insufficient resources
- Image compatibility issues

**Fix:** Run the permanent fix script
```bash
./permanent-fix-runner.sh
```

### 2. Connection Issues
**Symptoms:** "client connection lost", "TLS handshake timeout"
**Causes:**
- Kubernetes cluster not accessible
- Network connectivity issues
- kubelet service down

**Fix:**
```bash
# Check cluster status
kubectl cluster-info

# Restart kubelet (if local)
sudo systemctl restart kubelet

# Check if minikube is running
minikube status
```

### 3. Resource Constraints
**Symptoms:** Pod stuck in "Pending" state
**Causes:** Insufficient CPU/memory on nodes

**Fix:** The permanent fix includes optimized resource limits:
- Memory: 512Mi request, 1Gi limit
- CPU: 250m request, 500m limit

### 4. Token Expiration
**Symptoms:** Authentication errors in logs
**Fix:**
1. Get new token from GitHub: https://github.com/anthony-gilbert/Vue-Book-Tracker/settings/actions/runners
2. Set environment variable: `export GITHUB_RUNNER_TOKEN='your_new_token'`
3. Run: `./permanent-fix-runner.sh`

### 5. Monitoring and Health Checks

The permanent fix includes automatic monitoring:
- Health check every 5 minutes
- Automatic restart of failed pods
- Logging to `/tmp/runner-health.log`

Manual monitoring commands:
```bash
# Watch pod status
kubectl get pods -n github-runners -w

# View logs
kubectl logs -n github-runners -l app=github-runner -f

# Check runner registration
./monitor-runner.sh
```

## Key Improvements in Permanent Fix

1. **Stable Image Version:** Uses specific version instead of `latest`
2. **Better Resource Allocation:** Increased memory and CPU limits
3. **Improved Probes:** More reliable health checks with longer timeouts
4. **Graceful Shutdown:** Proper cleanup when pod terminates
5. **RBAC Security:** Service account with minimal required permissions
6. **Automatic Monitoring:** Cron job for continuous health monitoring
7. **Node Selection:** Ensures deployment on compatible architecture

## Prevention

- Use the permanent fix script for initial setup
- Monitor health logs regularly: `tail -f /tmp/runner-health.log`
- Refresh tokens before expiration (typically every 1 hour for registration tokens)
- Keep cluster nodes properly resourced

## Emergency Recovery

If runner is completely broken:
```bash
# Full cleanup and restart
kubectl delete namespace github-runners
kubectl create namespace github-runners
export GITHUB_RUNNER_TOKEN='fresh_token_here'
./permanent-fix-runner.sh
```
