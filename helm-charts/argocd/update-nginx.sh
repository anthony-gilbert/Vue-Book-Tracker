#!/bin/bash

# Update nginx configuration with current ArgoCD pod IPs
# Run this script if ArgoCD pods restart and you get 502 errors

set -e

DOMAIN="argocd.booktracker.dev"
NAMESPACE="argocd"

echo "Updating nginx configuration for $DOMAIN..."

# Get current ArgoCD server pod IP
ARGOCD_POD_IP=$(kubectl get endpoints argocd-server -n $NAMESPACE -o jsonpath='{.subsets[0].addresses[0].ip}')

if [ -z "$ARGOCD_POD_IP" ]; then
    echo "Error: Could not get ArgoCD server pod IP"
    echo "Make sure ArgoCD pods are running: kubectl get pods -n $NAMESPACE"
    exit 1
fi

echo "Current ArgoCD pod IP: $ARGOCD_POD_IP"

# Get current challenge pod IP if it exists
CHALLENGE_POD_IP=""
if kubectl get pods -n argocd | grep -q "cm-acme-http-solver"; then
    CHALLENGE_POD_IP=$(kubectl get endpoints -n argocd | grep cm-acme-http-solver | awk '{print $2}' | cut -d: -f1)
    echo "Current challenge pod IP: $CHALLENGE_POD_IP"
fi

# Get current configuration
CURRENT_ARGOCD_IP=$(grep -oP 'proxy_pass http://\K[^:]+' /etc/nginx/sites-available/argocd-proxy | grep -E '^10\.' | head -1)

if [ "$CURRENT_ARGOCD_IP" = "$ARGOCD_POD_IP" ]; then
    echo "✅ Nginx configuration is already up to date"
    exit 0
fi

echo "Updating ArgoCD pod IP from $CURRENT_ARGOCD_IP to $ARGOCD_POD_IP"

# Update ArgoCD pod IP in nginx config
sed -i "s|proxy_pass http://$CURRENT_ARGOCD_IP:8080|proxy_pass http://$ARGOCD_POD_IP:8080|g" /etc/nginx/sites-available/argocd-proxy

# Update challenge pod IP if it exists
if [ -n "$CHALLENGE_POD_IP" ]; then
    CURRENT_CHALLENGE_IP=$(grep -oP 'proxy_pass http://\K[^:]+(?=:8089)' /etc/nginx/sites-available/argocd-proxy || true)
    if [ -n "$CURRENT_CHALLENGE_IP" ] && [ "$CURRENT_CHALLENGE_IP" != "$CHALLENGE_POD_IP" ]; then
        echo "Updating challenge pod IP from $CURRENT_CHALLENGE_IP to $CHALLENGE_POD_IP"
        sed -i "s|proxy_pass http://$CURRENT_CHALLENGE_IP:8089|proxy_pass http://$CHALLENGE_POD_IP:8089|g" /etc/nginx/sites-available/argocd-proxy
    fi
fi

# Test and reload nginx
nginx -t
systemctl reload nginx

echo "✅ Nginx configuration updated successfully"
echo "🌐 ArgoCD should now be accessible at https://$DOMAIN"
