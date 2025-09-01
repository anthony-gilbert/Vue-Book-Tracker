#!/bin/bash

# GitHub Runner Restart Script with Resource Optimizations
# This script restarts the GitHub runner with better resource management

set -e

echo "🔄 Restarting GitHub Runner with optimized resources..."

# Clean up existing deployment
echo "Cleaning up existing resources..."
kubectl delete deployment github-runner -n github-runners --ignore-not-found=true
kubectl delete secret github-runner-token -n github-runners --ignore-not-found=true

# Check for GitHub token
if [ -z "$GITHUB_RUNNER_TOKEN" ]; then
    echo ""
    echo "❌ ERROR: GITHUB_RUNNER_TOKEN environment variable is required"
    echo ""
    echo "To get a new token:"
    echo "1. Go to: https://github.com/anthony-gilbert/Vue-Book-Tracker/settings/actions/runners"
    echo "2. Click 'New self-hosted runner'"
    echo "3. Copy the registration token"
    echo "4. Run: export GITHUB_RUNNER_TOKEN='your_token_here'"
    echo "5. Then run this script again"
    exit 1
fi

echo "Creating namespace if it doesn't exist..."
kubectl apply -f namespace.yaml

echo "Creating secret with new token..."
kubectl create secret generic github-runner-token \
  --from-literal=token=$GITHUB_RUNNER_TOKEN \
  --namespace=github-runners

echo "Applying optimized deployment..."
kubectl apply -f deployment.yaml

echo "✅ GitHub Runner restart complete!"
echo ""
echo "Monitor status with:"
echo "  kubectl get pods -n github-runners"
echo "  kubectl logs -n github-runners -l app=github-runner -f"
