#!/bin/bash

# Nginx Setup Script for ArgoCD
# Usage: ./setup-nginx.sh <domain> <argocd_pod_ip> <server_ip>

set -e

DOMAIN=${1:-"argocd.booktracker.dev"}
ARGOCD_POD_IP=${2:-""}
SERVER_IP=${3:-"143.198.49.14"}

if [ -z "$ARGOCD_POD_IP" ]; then
    echo "Error: ArgoCD pod IP is required"
    echo "Usage: $0 <domain> <argocd_pod_ip> <server_ip>"
    exit 1
fi

echo "Setting up nginx reverse proxy for $DOMAIN..."

# Install ssl-cert if not present
if ! dpkg -l | grep -q ssl-cert; then
    echo "Installing ssl-cert..."
    apt-get update && apt-get install -y ssl-cert
fi

# Get current challenge pod IP if it exists
CHALLENGE_POD_IP=""
if kubectl get pods -n argocd | grep -q "cm-acme-http-solver"; then
    CHALLENGE_POD_IP=$(kubectl get endpoints -n argocd | grep cm-acme-http-solver | awk '{print $2}' | cut -d: -f1)
fi

# Create nginx configuration
cat > /etc/nginx/sites-available/argocd-proxy << EOF
server {
    listen 80;
    server_name $DOMAIN;
    
    # Handle Let's Encrypt challenges if active
EOF

if [ -n "$CHALLENGE_POD_IP" ]; then
    cat >> /etc/nginx/sites-available/argocd-proxy << EOF
    location /.well-known/acme-challenge/ {
        proxy_pass http://$CHALLENGE_POD_IP:8089;
        proxy_set_header Host \$host;
    }
    
EOF
fi

cat >> /etc/nginx/sites-available/argocd-proxy << EOF
    location / {
        return 301 https://\$server_name\$request_uri;
    }
}

server {
    listen 443 ssl;
    server_name $DOMAIN;
    
    # SSL certificate (will be replaced by Let's Encrypt when ready)
    ssl_certificate /etc/ssl/certs/ssl-cert-snakeoil.pem;
    ssl_certificate_key /etc/ssl/private/ssl-cert-snakeoil.key;
    
    location / {
        proxy_pass http://$ARGOCD_POD_IP:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_redirect off;
    }
}
EOF

# Enable site
ln -sf /etc/nginx/sites-available/argocd-proxy /etc/nginx/sites-enabled/

# Remove default site if it exists
rm -f /etc/nginx/sites-enabled/default

# Test and restart nginx
nginx -t
systemctl restart nginx

echo "✅ Nginx configured successfully for $DOMAIN -> $ARGOCD_POD_IP:8080"
