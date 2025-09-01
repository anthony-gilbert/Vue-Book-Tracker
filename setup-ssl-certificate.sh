#!/bin/bash

# Setup SSL certificate for booktracker.dev
echo "Setting up SSL certificate for booktracker.dev..."

# Check if certbot is installed
if ! command -v certbot &> /dev/null; then
    echo "Installing certbot..."
    sudo apt update
    sudo apt install -y certbot python3-certbot-nginx
fi

# Stop nginx temporarily to allow certbot to bind to port 80
sudo systemctl stop nginx

# Obtain SSL certificate
sudo certbot certonly --standalone \
    --email admin@booktracker.dev \
    --agree-tos \
    --no-eff-email \
    -d booktracker.dev

# Start nginx back up
sudo systemctl start nginx

echo "SSL certificate setup complete!"
echo "Certificate files should now be available at:"
echo "  /etc/letsencrypt/live/booktracker.dev/fullchain.pem"
echo "  /etc/letsencrypt/live/booktracker.dev/privkey.pem"
