#!/bin/bash

# Update nginx configuration with current ArgoCD service IPs (more stable than pod IPs)
# This ensures ArgoCD connectivity after deployments

set -e

DOMAIN="argocd.booktracker.dev"
NAMESPACE="argocd"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_FILE="$SCRIPT_DIR/../../nginx-config/argocd-proxy.template"
NGINX_CONFIG="/etc/nginx/sites-available/argocd-proxy"

echo "🔧 Updating nginx configuration for $DOMAIN..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ Error: kubectl is not available"
    echo "Please install kubectl or make sure it's in PATH"
    exit 1
fi

# Check if we can connect to Kubernetes cluster (skip in CI/CD environments)
if [ "$GITHUB_ACTIONS" = "true" ] || [ "$CI" = "true" ] || [ -n "$RUNNER_OS" ] || [ -n "$GITHUB_WORKFLOW" ]; then
    echo "🤖 CI/CD environment detected - nginx scripts will be deployed"
    echo "✅ Configuration will be applied during actual deployment"
    exit 0
fi

if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Error: Cannot connect to Kubernetes cluster"
    echo "Make sure kubectl is configured properly"
    exit 1
fi

# Get ArgoCD server service IP (stable)
ARGOCD_SERVICE_IP=$(kubectl get service argocd-server -n $NAMESPACE -o jsonpath='{.spec.clusterIP}' 2>/dev/null)

if [ -z "$ARGOCD_SERVICE_IP" ]; then
    echo "❌ Error: Could not get ArgoCD server service IP"
    echo "Make sure ArgoCD service exists: kubectl get svc -n $NAMESPACE"
    kubectl get svc -n $NAMESPACE || true
    exit 1
fi

echo "📍 ArgoCD service IP: $ARGOCD_SERVICE_IP"

# Get current challenge pod IP if it exists (for Let's Encrypt)
CHALLENGE_SERVICE_IP="10.42.0.35"  # Default fallback
if kubectl get pods -n argocd 2>/dev/null | grep -q "cm-acme-http-solver"; then
    CHALLENGE_POD_IP=$(kubectl get pods -n argocd -o wide 2>/dev/null | grep "cm-acme-http-solver" | awk '{print $6}' | head -1)
    if [ -n "$CHALLENGE_POD_IP" ]; then
        CHALLENGE_SERVICE_IP="$CHALLENGE_POD_IP"
    fi
fi

echo "🔒 Challenge service IP: $CHALLENGE_SERVICE_IP"

# Check if template exists
if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "❌ Template file not found: $TEMPLATE_FILE"
    exit 1
fi

# Create nginx config from template
echo "📝 Generating nginx configuration from template..."
cp "$TEMPLATE_FILE" "$NGINX_CONFIG"

# Replace placeholders
sed -i "s|{{ARGOCD_SERVICE_IP}}|$ARGOCD_SERVICE_IP|g" "$NGINX_CONFIG"
sed -i "s|{{CHALLENGE_SERVICE_IP}}|$CHALLENGE_SERVICE_IP|g" "$NGINX_CONFIG"

# Test nginx configuration
echo "✅ Testing nginx configuration..."
if ! nginx -t; then
    echo "❌ Nginx configuration test failed"
    exit 1
fi

# Reload nginx
echo "🔄 Reloading nginx..."
systemctl reload nginx

echo "✅ Nginx configuration updated successfully"
echo "🌐 ArgoCD should now be accessible at https://$DOMAIN"
echo "🔍 Service-based configuration is more stable than pod-based"
