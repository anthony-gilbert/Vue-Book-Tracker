#!/bin/bash

# GitHub Actions Self-hosted Runner Cleanup Script
# This script removes the GitHub Actions self-hosted runner from Kubernetes

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_status "Cleaning up GitHub Actions self-hosted runner..."

# Remove deployment
print_status "Removing deployment..."
kubectl delete -f deployment.yaml --ignore-not-found=true

# Remove secret
print_status "Removing secret..."
kubectl delete secret github-runner-token -n github-runners --ignore-not-found=true

# Remove namespace (this will remove everything in it)
read -p "Do you want to remove the entire github-runners namespace? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Removing namespace..."
    kubectl delete -f namespace.yaml --ignore-not-found=true
    print_status "✅ GitHub Actions runner completely removed!"
else
    print_status "✅ GitHub Actions runner deployment removed (namespace kept)!"
fi

print_warning "Note: The runner may still appear in GitHub for a few minutes until GitHub detects it's offline."
