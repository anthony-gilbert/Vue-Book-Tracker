#!/bin/bash

# Test script to verify the GitHub runner setup
# This script tests the deployment without actually deploying

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[TEST]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[CHECK]${NC} $1"
}

print_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

print_status "Testing GitHub Actions Runner Setup..."

# Check if files exist
files=("namespace.yaml" "deployment.yaml" "setup.sh" "cleanup.sh" "scale.sh" "README.md")

print_status "Checking required files..."
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        print_status "✅ $file exists"
    else
        print_error "❌ $file missing"
        exit 1
    fi
done

# Validate YAML files
print_status "Validating YAML syntax..."
if command -v kubectl &> /dev/null; then
    kubectl apply --dry-run=client -f namespace.yaml > /dev/null 2>&1
    print_status "✅ namespace.yaml is valid"
    
    kubectl apply --dry-run=client -f deployment.yaml > /dev/null 2>&1
    print_status "✅ deployment.yaml is valid"
else
    print_warning "⚠️  kubectl not found, skipping YAML validation"
fi

# Check script permissions
print_status "Checking script permissions..."
for script in setup.sh cleanup.sh scale.sh; do
    if [ -x "$script" ]; then
        print_status "✅ $script is executable"
    else
        print_warning "⚠️  $script is not executable (run: chmod +x $script)"
    fi
done

# Check if current runner is still running (if exists)
if command -v kubectl &> /dev/null; then
    if kubectl get namespace github-runners &> /dev/null; then
        print_warning "⚠️  github-runners namespace already exists"
        if kubectl get deployment github-runner -n github-runners &> /dev/null; then
            print_warning "⚠️  github-runner deployment already exists"
            CURRENT_REPLICAS=$(kubectl get deployment github-runner -n github-runners -o jsonpath='{.spec.replicas}')
            print_warning "⚠️  Current replicas: $CURRENT_REPLICAS"
        fi
    else
        print_status "✅ No existing github-runners namespace found"
    fi
fi

print_status ""
print_status "🎉 All tests passed! The setup is ready to use."
print_status ""
print_status "To deploy:"
print_status "1. Get a GitHub registration token from:"
print_status "   https://github.com/anthony-gilbert/Vue-Book-Tracker/settings/actions/runners"
print_status "2. Run: ./setup.sh"
print_status ""
print_status "To test with existing runner:"
print_status "   kubectl get pods -n github-runners"
print_status "   kubectl logs -n github-runners -l app=github-runner"
