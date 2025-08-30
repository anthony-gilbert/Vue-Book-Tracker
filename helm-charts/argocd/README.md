# ArgoCD Helm Configuration

This directory contains the Helm configuration for deploying ArgoCD with external domain access.

## Quick Setup

1. **Add DNS record** for your domain pointing to your server IP:
   ```
   Type: A
   Name: argocd.booktracker.dev
   Value: 143.198.49.14
   ```

2. **Run the setup script**:
   ```bash
   chmod +x setup.sh setup-nginx.sh update-nginx.sh
   ./setup.sh
   ```

3. **Access ArgoCD**:
   - URL: https://argocd.booktracker.dev
   - Username: `admin`
   - Password: Run `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`

## Files

- `values-argo.yaml` - Helm values for ArgoCD configuration
- `cluster-issuer.yaml` - Let's Encrypt certificate issuer
- `certificate.yaml` - SSL certificate configuration
- `setup.sh` - Main setup script
- `setup-nginx.sh` - Nginx reverse proxy setup
- `update-nginx.sh` - Update nginx when pods restart
- `Argo-Fix.md` - Detailed troubleshooting documentation

## Manual Setup

If the automated setup doesn't work, follow these steps:

### 1. Install ArgoCD
```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
kubectl create namespace argocd
helm install argocd argo/argo-cd -n argocd -f values-argo.yaml
```

### 2. Configure SSL Certificates
```bash
kubectl apply -f cluster-issuer.yaml
kubectl apply -f certificate.yaml
```

### 3. Configure ArgoCD for Reverse Proxy
```bash
kubectl patch configmap argocd-cmd-params-cm -n argocd --type merge -p '{"data":{"server.insecure":"true"}}'
kubectl patch configmap argocd-cm -n argocd --type merge -p '{"data":{"url":"https://argocd.booktracker.dev"}}'
kubectl rollout restart deployment argocd-server -n argocd
```

### 4. Setup Nginx Reverse Proxy
```bash
# Get ArgoCD pod IP
ARGOCD_POD_IP=$(kubectl get endpoints argocd-server -n argocd -o jsonpath='{.subsets[0].addresses[0].ip}')

# Run nginx setup
./setup-nginx.sh argocd.booktracker.dev $ARGOCD_POD_IP
```

## Troubleshooting

### 502 Bad Gateway
This usually means ArgoCD pods have restarted and have new IPs. Run:
```bash
./update-nginx.sh
```

### Redirect Loop
Make sure ArgoCD is configured with `server.insecure: true`:
```bash
kubectl get configmap argocd-cmd-params-cm -n argocd -o yaml | grep insecure
```

### Certificate Issues
Check certificate status:
```bash
kubectl get certificate -n argocd
kubectl describe certificate argocd-server-tls -n argocd
```

### DNS Issues
Verify DNS resolution:
```bash
dig argocd.booktracker.dev
nslookup argocd.booktracker.dev
```

## Configuration Details

- **ArgoCD Version**: v3.1.1
- **Ingress**: Traefik with NodePort service
- **SSL**: Let's Encrypt via cert-manager
- **Reverse Proxy**: Nginx handling external traffic
- **Authentication**: Default admin user
