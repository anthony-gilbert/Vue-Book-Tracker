#!/bin/bash

# ArgoCD Status Check Script

DOMAIN="argocd.booktracker.dev"
NAMESPACE="argocd"

echo "🔍 Checking ArgoCD status..."
echo ""

# Check DNS
echo "📡 DNS Resolution:"
if dig +short $DOMAIN | grep -q "143.198.49.14"; then
    echo "  ✅ DNS resolves correctly"
else
    echo "  ❌ DNS not resolving to correct IP"
    echo "  Expected: 143.198.49.14"
    echo "  Actual: $(dig +short $DOMAIN)"
fi
echo ""

# Check Kubernetes pods
echo "🚀 Kubernetes Pods:"
kubectl get pods -n $NAMESPACE | grep -E "(NAME|argocd-server)"
echo ""

# Check services
echo "🔗 Services & Endpoints:"
kubectl get svc argocd-server -n $NAMESPACE
kubectl get endpoints argocd-server -n $NAMESPACE
echo ""

# Check certificates
echo "🔒 SSL Certificates:"
kubectl get certificate -n $NAMESPACE 2>/dev/null || echo "  No certificates found"
echo ""

# Check ingress
echo "🌐 Ingress:"
kubectl get ingress -n $NAMESPACE
echo ""

# Test HTTP connectivity
echo "🌍 HTTP Connectivity:"
if curl -s -o /dev/null -w "%{http_code}" http://$DOMAIN | grep -q "301"; then
    echo "  ✅ HTTP redirects to HTTPS correctly"
else
    echo "  ❌ HTTP not working properly"
fi

# Test HTTPS connectivity
echo "🔐 HTTPS Connectivity:"
HTTP_CODE=$(curl -k -s -o /dev/null -w "%{http_code}" https://$DOMAIN)
if [ "$HTTP_CODE" = "200" ]; then
    echo "  ✅ HTTPS working correctly"
    echo "  🌐 ArgoCD is accessible at https://$DOMAIN"
else
    echo "  ❌ HTTPS returning $HTTP_CODE"
fi
echo ""

# Get admin password
echo "🔑 Admin Credentials:"
echo "  Username: admin"
if kubectl get secret argocd-initial-admin-secret -n $NAMESPACE &>/dev/null; then
    PASSWORD=$(kubectl -n $NAMESPACE get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
    echo "  Password: $PASSWORD"
else
    echo "  ❌ Initial admin secret not found"
fi
echo ""

# Show current nginx config
echo "⚙️  Current Nginx Configuration:"
if [ -f /etc/nginx/sites-available/argocd-proxy ]; then
    echo "  Proxying to: $(grep proxy_pass /etc/nginx/sites-available/argocd-proxy | grep -v challenge | awk '{print $2}' | tr -d ';')"
else
    echo "  ❌ Nginx configuration not found"
fi
