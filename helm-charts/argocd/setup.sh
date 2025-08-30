#!/bin/bash

# ArgoCD Setup Script
# This script sets up ArgoCD with external domain access

set -e

DOMAIN="argocd.booktracker.dev"
NAMESPACE="argocd"
SERVER_IP="143.198.49.14"

echo "Setting up ArgoCD at $DOMAIN..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "kubectl is required but not installed"
    exit 1
fi

# Check if helm is available
if ! command -v helm &> /dev/null; then
    echo "helm is required but not installed"
    exit 1
fi

# Add ArgoCD helm repo
echo "Adding ArgoCD helm repository..."
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Create namespace
echo "Creating namespace $NAMESPACE..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Apply SSL certificate configuration
echo "Setting up SSL certificates..."
kubectl apply -f cluster-issuer.yaml
kubectl apply -f certificate.yaml

# Install ArgoCD
echo "Installing ArgoCD..."
helm upgrade --install argocd argo/argo-cd -n $NAMESPACE -f values-argo.yaml

# Wait for pods to be ready
echo "Waiting for ArgoCD pods to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n $NAMESPACE --timeout=300s

# Configure ArgoCD for reverse proxy
echo "Configuring ArgoCD for reverse proxy..."
kubectl patch configmap argocd-cmd-params-cm -n $NAMESPACE --type merge -p '{"data":{"server.insecure":"true"}}'
kubectl patch configmap argocd-cm -n $NAMESPACE --type merge -p "{\"data\":{\"url\":\"https://$DOMAIN\"}}"

# Restart ArgoCD server to apply config
echo "Restarting ArgoCD server..."
kubectl rollout restart deployment argocd-server -n $NAMESPACE
kubectl rollout status deployment argocd-server -n $NAMESPACE

# Fix Traefik LoadBalancer issue
echo "Configuring Traefik service..."
kubectl patch svc traefik -n kube-system -p '{"spec":{"type":"NodePort"}}'

# Get ArgoCD pod IP for nginx configuration
echo "Getting ArgoCD server endpoint..."
ARGOCD_POD_IP=$(kubectl get endpoints argocd-server -n $NAMESPACE -o jsonpath='{.subsets[0].addresses[0].ip}')
echo "ArgoCD pod IP: $ARGOCD_POD_IP"

# Setup nginx reverse proxy
echo "Setting up nginx reverse proxy..."
./setup-nginx.sh "$DOMAIN" "$ARGOCD_POD_IP" "$SERVER_IP"

# Get admin password
echo "Getting ArgoCD admin password..."
ADMIN_PASSWORD=$(kubectl -n $NAMESPACE get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo ""
echo "✅ ArgoCD setup complete!"
echo ""
echo "🌐 URL: https://$DOMAIN"
echo "👤 Username: admin"
echo "🔑 Password: $ADMIN_PASSWORD"
echo ""
echo "📝 Make sure you have added the following DNS record:"
echo "   Type: A"
echo "   Name: $DOMAIN"
echo "   Value: $SERVER_IP"
echo ""
echo "⚠️  Note: If ArgoCD pods restart, you may need to run update-nginx.sh to update pod IPs"
