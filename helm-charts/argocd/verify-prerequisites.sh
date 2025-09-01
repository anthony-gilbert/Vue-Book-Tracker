#!/bin/bash

# Verify all prerequisites for ArgoCD deployment
# Run this script to check if the system is ready for ArgoCD operations

set -e

echo "🔍 Verifying prerequisites for ArgoCD deployment..."

# Check if running as root (for nginx operations)
if [[ $EUID -ne 0 ]]; then
   echo "❌ This script must be run as root (for nginx configuration)"
   echo "💡 Try: sudo $0"
   exit 1
fi

# Check kubectl availability
echo "📦 Checking kubectl..."
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl not found"
    echo "💡 Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
    echo "✅ kubectl installed successfully"
else
    echo "✅ kubectl found"
fi

# Check Kubernetes cluster connectivity
echo "🔗 Checking Kubernetes cluster connectivity..."
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster"
    echo "💡 Make sure k3s is running and kubectl is configured"
    systemctl status k3s --no-pager || true
    exit 1
else
    echo "✅ Kubernetes cluster is accessible"
fi

# Check if ArgoCD namespace exists
echo "🏷️  Checking ArgoCD namespace..."
if ! kubectl get namespace argocd &> /dev/null; then
    echo "❌ ArgoCD namespace not found"
    echo "💡 Make sure ArgoCD is installed: kubectl get ns"
    exit 1
else
    echo "✅ ArgoCD namespace exists"
fi

# Check if ArgoCD service exists
echo "🌐 Checking ArgoCD service..."
if ! kubectl get service argocd-server -n argocd &> /dev/null; then
    echo "❌ ArgoCD server service not found"
    echo "💡 Make sure ArgoCD is running: kubectl get svc -n argocd"
    exit 1
else
    ARGOCD_SERVICE_IP=$(kubectl get service argocd-server -n argocd -o jsonpath='{.spec.clusterIP}')
    echo "✅ ArgoCD service found (IP: $ARGOCD_SERVICE_IP)"
fi

# Check nginx
echo "🌍 Checking nginx..."
if ! command -v nginx &> /dev/null; then
    echo "❌ nginx not found"
    exit 1
else
    echo "✅ nginx found"
fi

# Check nginx configuration directory
if [ ! -d "/etc/nginx/sites-available" ]; then
    echo "❌ nginx sites-available directory not found"
    exit 1
else
    echo "✅ nginx configuration directory exists"
fi

# Check system resources
AVAILABLE_MEM=$(free -m | awk 'NR==2{printf "%.0f", $7}')
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')

echo "💾 System resources check:"
echo "   Available memory: ${AVAILABLE_MEM}MB"
echo "   Disk usage: ${DISK_USAGE}%"

if [ "$AVAILABLE_MEM" -lt 100 ]; then
    echo "⚠️  Low memory warning (< 100MB available)"
fi

if [ "$DISK_USAGE" -gt 90 ]; then
    echo "⚠️  High disk usage warning (> 90%)"
fi

echo ""
echo "✅ All prerequisites verified successfully!"
echo "🚀 System is ready for ArgoCD deployment operations"
