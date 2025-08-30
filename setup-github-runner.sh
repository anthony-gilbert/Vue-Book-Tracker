#!/bin/bash

# GitHub Actions Runner Controller Setup Script
# This script installs the GitHub Actions Runner Controller using Helm

set -e

echo "Setting up GitHub Actions Runner Controller..."

# Check required environment variable
if [ -z "$GITHUB_RUNNER_TOKEN" ]; then
    echo "ERROR: GITHUB_RUNNER_TOKEN environment variable is required"
    echo "Please set it with: export GITHUB_RUNNER_TOKEN=your_token_here"
    exit 1
fi

# Install Actions Runner Controller
echo "Installing Actions Runner Controller with Helm..."
helm upgrade --install --namespace actions-runner-system --create-namespace \
  --set=authSecret.create=true \
  --set=authSecret.github_token=$GITHUB_RUNNER_TOKEN \
  --wait actions-runner-controller actions-runner-controller/actions-runner-controller

echo "✅ GitHub Actions Runner Controller setup complete!"
echo ""
echo "Note: Make sure to replace any previous usage of GITHUB_TOKEN with GITHUB_RUNNER_TOKEN"
