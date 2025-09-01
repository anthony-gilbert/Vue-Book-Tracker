#!/bin/bash

# Test script to simulate the complete CI/CD deployment process
# This script mimics what happens in the GitHub Actions pipeline

set -e

echo "🧪 Testing complete ArgoCD deployment process..."
echo "=================================================="

# Step 1: Verify prerequisites
echo "1️⃣  Verifying prerequisites..."
chmod +x verify-prerequisites.sh
sudo ./verify-prerequisites.sh

# Step 2: Prepare system
echo ""
echo "2️⃣  Preparing system resources..."
chmod +x setup-system.sh
sudo ./setup-system.sh

# Step 3: Update nginx configuration  
echo ""
echo "3️⃣  Updating nginx configuration..."
chmod +x update-nginx.sh
sudo ./update-nginx.sh

# Step 4: Test ArgoCD connectivity
echo ""
echo "4️⃣  Testing ArgoCD connectivity..."
echo "🌐 Testing HTTPS connection..."
if curl -s -k https://argocd.booktracker.dev/ | grep -q "Argo CD"; then
    echo "✅ ArgoCD web interface is accessible"
else
    echo "❌ ArgoCD web interface test failed"
    exit 1
fi

# Step 5: Test ArgoCD pods
echo ""
echo "5️⃣  Checking ArgoCD pod status..."
kubectl get pods -n argocd --no-headers | while read line; do
    pod_name=$(echo $line | awk '{print $1}')
    pod_status=$(echo $line | awk '{print $3}')
    if [ "$pod_status" != "Running" ]; then
        echo "⚠️  Pod $pod_name is not running (status: $pod_status)"
    else
        echo "✅ Pod $pod_name is running"
    fi
done

# Step 6: Test nginx configuration
echo ""
echo "6️⃣  Testing nginx configuration..."
if nginx -t 2>/dev/null; then
    echo "✅ Nginx configuration is valid"
else
    echo "❌ Nginx configuration test failed"
    exit 1
fi

echo ""
echo "🎉 All tests passed successfully!"
echo "🚀 ArgoCD deployment process is working correctly"
echo "🌐 ArgoCD is accessible at: https://argocd.booktracker.dev/"
