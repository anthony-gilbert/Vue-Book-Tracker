#!/bin/bash

# GitHub Actions Runner Scaling Script
# Scale the number of runner instances up or down

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if argument is provided
if [ $# -eq 0 ]; then
    print_error "Usage: $0 <number_of_replicas>"
    print_error "Example: $0 3  # Scale to 3 runner instances"
    exit 1
fi

REPLICAS=$1

# Validate input is a number
if ! [[ "$REPLICAS" =~ ^[0-9]+$ ]]; then
    print_error "Please provide a valid number of replicas"
    exit 1
fi

# Scale the deployment
print_status "Scaling GitHub Actions runners to $REPLICAS replicas..."
kubectl scale deployment github-runner --replicas=$REPLICAS -n github-runners

# Wait for scaling to complete
print_status "Waiting for scaling to complete..."
kubectl rollout status deployment/github-runner -n github-runners --timeout=300s

# Show current status
print_status "Current runner status:"
kubectl get pods -n github-runners -l app=github-runner

if [ "$REPLICAS" -gt 1 ]; then
    print_warning "Note: Multiple runners will appear in GitHub with names like:"
    print_warning "k8s-self-hosted-runner, k8s-self-hosted-runner-1, k8s-self-hosted-runner-2, etc."
fi

print_status "✅ Successfully scaled to $REPLICAS runner instances!"
