#!/bin/bash

# GitHub Actions Self-hosted Runner Setup Script
# This script sets up a GitHub Actions self-hosted runner in Kubernetes

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

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Check if we're connected to a Kubernetes cluster
if ! kubectl cluster-info &> /dev/null; then
    print_error "Cannot connect to Kubernetes cluster. Please check your kubeconfig."
    exit 1
fi

print_status "Setting up GitHub Actions self-hosted runner..."

# Get the GitHub runner token from user
if [ -z "$GITHUB_RUNNER_TOKEN" ]; then
    echo ""
    print_warning "You need to get a runner registration token from GitHub:"
    echo "1. Go to: https://github.com/anthony-gilbert/Vue-Book-Tracker/settings/actions/runners"
    echo "2. Click 'New self-hosted runner'"
    echo "3. Copy the registration token (starts with 'A' and is about 29 characters)"
    echo ""
    read -p "Enter the GitHub runner registration token: " GITHUB_RUNNER_TOKEN
    
    if [ -z "$GITHUB_RUNNER_TOKEN" ]; then
        print_error "GitHub runner token is required!"
        exit 1
    fi
fi

# Create namespace
print_status "Creating namespace..."
kubectl apply -f namespace.yaml

# Create secret with the token
print_status "Creating secret with GitHub runner token..."
kubectl create secret generic github-runner-token \
    --namespace github-runners \
    --from-literal=token="$GITHUB_RUNNER_TOKEN" \
    --dry-run=client -o yaml | kubectl apply -f -

# Deploy the runner
print_status "Deploying GitHub Actions runner..."
kubectl apply -f deployment.yaml

# Wait for deployment to be ready
print_status "Waiting for deployment to be ready..."
kubectl rollout status deployment/github-runner -n github-runners --timeout=300s

# Get pod status
print_status "Checking runner status..."
kubectl get pods -n github-runners -l app=github-runner

# Show logs
print_status "Recent runner logs:"
kubectl logs -n github-runners -l app=github-runner --tail=10

echo ""
print_status "✅ GitHub Actions self-hosted runner has been deployed successfully!"
echo ""
print_warning "Note: The registration token expires in 1 hour. If you need to redeploy later,"
print_warning "you'll need to get a new token from the GitHub repository settings."
echo ""
print_status "You can now use 'runs-on: self-hosted' in your GitHub Actions workflows."
echo ""
print_status "To check the runner status: kubectl get pods -n github-runners"
print_status "To view runner logs: kubectl logs -n github-runners -l app=github-runner"
