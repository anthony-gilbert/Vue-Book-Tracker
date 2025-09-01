#!/bin/bash

# Simple ArgoCD fix using self-signed certificate and basic nginx config
echo "Fixing ArgoCD access with simple configuration..."

# Create a basic nginx config that uses self-signed cert
cat > /tmp/argocd-simple.conf << 'EOF'
server {
    listen 80;
    server_name argocd.booktracker.dev;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    server_name argocd.booktracker.dev;

    # Use self-signed certificate temporarily
    ssl_certificate /etc/ssl/certs/ssl-cert-snakeoil.pem;
    ssl_certificate_key /etc/ssl/private/ssl-cert-snakeoil.key;

    location / {
        proxy_pass http://10.43.54.4:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_redirect off;
        
        # Add some timeouts
        proxy_connect_timeout 10s;
        proxy_send_timeout 10s;
        proxy_read_timeout 10s;
    }
}
EOF

# Apply the configuration
sudo cp /tmp/argocd-simple.conf /etc/nginx/sites-available/argocd.booktracker.dev
sudo nginx -t && sudo systemctl reload nginx

echo "Simple ArgoCD configuration applied!"
echo "ArgoCD should be accessible at https://argocd.booktracker.dev"
echo "Note: This uses a self-signed certificate, so you'll get a warning"
