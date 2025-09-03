#!/bin/bash

# Permanent GitHub Runner Fix Script
# This script addresses common crash issues and creates a stable runner setup

set -e

echo "🔧 Applying permanent fix for GitHub Runner crashes..."

# Function to check if kubectl is working
check_kubectl() {
    if ! kubectl cluster-info &>/dev/null; then
        echo "❌ Kubernetes cluster not accessible. Checking connection..."
        
        # Try to restart kubelet
        sudo systemctl restart kubelet 2>/dev/null || echo "Could not restart kubelet (may not be running locally)"
        
        # Wait and retry
        sleep 5
        if ! kubectl cluster-info &>/dev/null; then
            echo "❌ Still cannot connect to Kubernetes cluster"
            echo "Please ensure your cluster is running and kubectl is configured properly"
            echo "For minikube: minikube start"
            echo "For kind: kind create cluster"
            exit 1
        fi
    fi
    echo "✅ Kubernetes cluster is accessible"
}

# Function to clean up old resources safely
cleanup_old_resources() {
    echo "🧹 Cleaning up old runner resources..."
    
    # Remove old deployment
    kubectl delete deployment github-runner -n github-runners --ignore-not-found=true --timeout=60s
    
    # Remove old pods that might be stuck
    kubectl delete pods -n github-runners -l app=github-runner --ignore-not-found=true --timeout=60s
    
    # Keep the secret but recreate if token provided
    if [ ! -z "$GITHUB_RUNNER_TOKEN" ]; then
        kubectl delete secret github-runner-token -n github-runners --ignore-not-found=true
        echo "🔐 Creating fresh token secret..."
        kubectl create secret generic github-runner-token \
          --from-literal=token=$GITHUB_RUNNER_TOKEN \
          --namespace=github-runners
    fi
    
    echo "✅ Cleanup complete"
}

# Function to create namespace and apply resources
setup_runner() {
    echo "🚀 Setting up improved runner deployment..."
    
    # Ensure namespace exists
    kubectl apply -f namespace.yaml
    
    # Apply the fixed deployment
    kubectl apply -f fix-runner-deployment.yaml
    
    echo "⏳ Waiting for deployment to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/github-runner -n github-runners
    
    echo "✅ Runner deployment is ready!"
}

# Function to setup monitoring
setup_monitoring() {
    echo "📊 Setting up runner monitoring..."
    
    # Create a monitoring script that runs as a cron job
    cat > /tmp/runner-health-check.sh << 'EOF'
#!/bin/bash
# Health check script for GitHub runner

NAMESPACE="github-runners"
DEPLOYMENT="github-runner"
LOG_FILE="/tmp/runner-health.log"

# Function to log with timestamp
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
}

# Check if deployment exists and is ready
if ! kubectl get deployment $DEPLOYMENT -n $NAMESPACE &>/dev/null; then
    log_message "ERROR: Deployment $DEPLOYMENT not found"
    exit 1
fi

# Get deployment status
READY_REPLICAS=$(kubectl get deployment $DEPLOYMENT -n $NAMESPACE -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
DESIRED_REPLICAS=$(kubectl get deployment $DEPLOYMENT -n $NAMESPACE -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "1")

if [ "$READY_REPLICAS" != "$DESIRED_REPLICAS" ]; then
    log_message "WARNING: Runner not ready. Ready: $READY_REPLICAS, Desired: $DESIRED_REPLICAS"
    
    # Check for CrashLoopBackOff or other issues
    POD_STATUS=$(kubectl get pods -n $NAMESPACE -l app=github-runner -o jsonpath='{.items[0].status.phase}' 2>/dev/null || echo "Unknown")
    log_message "Pod status: $POD_STATUS"
    
    # If pod is in error state, try to restart
    if [[ "$POD_STATUS" == "Failed" || "$POD_STATUS" == "Unknown" ]]; then
        log_message "Restarting failed pod..."
        kubectl delete pods -n $NAMESPACE -l app=github-runner --ignore-not-found=true
    fi
else
    log_message "OK: Runner is healthy"
fi
EOF

    chmod +x /tmp/runner-health-check.sh
    sudo mv /tmp/runner-health-check.sh /usr/local/bin/runner-health-check.sh
    
    # Setup cron job for monitoring (every 5 minutes)
    (crontab -l 2>/dev/null; echo "*/5 * * * * /usr/local/bin/runner-health-check.sh") | crontab -
    
    echo "✅ Health monitoring setup complete"
}

# Function to validate the fix
validate_fix() {
    echo "🔍 Validating the fix..."
    
    # Wait a bit for the runner to fully start
    sleep 30
    
    # Check pod status
    POD_NAME=$(kubectl get pods -n github-runners -l app=github-runner -o jsonpath="{.items[0].metadata.name}" 2>/dev/null)
    if [ ! -z "$POD_NAME" ]; then
        POD_STATUS=$(kubectl get pod $POD_NAME -n github-runners -o jsonpath='{.status.phase}')
        echo "Pod $POD_NAME status: $POD_STATUS"
        
        if [ "$POD_STATUS" == "Running" ]; then
            echo "✅ Runner pod is running successfully"
            
            # Show recent logs
            echo "📋 Recent runner logs:"
            kubectl logs $POD_NAME -n github-runners --tail=5
        else
            echo "⚠️  Pod is not running. Status: $POD_STATUS"
            kubectl describe pod $POD_NAME -n github-runners | tail -20
        fi
    else
        echo "❌ No runner pod found"
        kubectl get pods -n github-runners
    fi
}

# Main execution
main() {
    echo "🎯 Starting GitHub Runner Permanent Fix"
    echo "======================================"
    
    # Check for required token
    if [ -z "$GITHUB_RUNNER_TOKEN" ]; then
        echo "⚠️  No GITHUB_RUNNER_TOKEN provided."
        echo "The script will proceed with existing secret if available."
        echo ""
        echo "To get a fresh token:"
        echo "1. Go to: https://github.com/anthony-gilbert/Vue-Book-Tracker/settings/actions/runners"
        echo "2. Click 'New self-hosted runner'"
        echo "3. Copy the registration token"
        echo "4. Run: export GITHUB_RUNNER_TOKEN='your_token_here'"
        echo ""
        read -p "Continue with existing setup? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Aborted. Please set GITHUB_RUNNER_TOKEN and run again."
            exit 1
        fi
    fi
    
    check_kubectl
    cleanup_old_resources
    setup_runner
    setup_monitoring
    validate_fix
    
    echo ""
    echo "🎉 Permanent fix applied successfully!"
    echo ""
    echo "Monitor your runner with:"
    echo "  kubectl get pods -n github-runners -w"
    echo "  kubectl logs -n github-runners -l app=github-runner -f"
    echo "  ./monitor-runner.sh"
    echo ""
    echo "Health monitoring is now active and will:"
    echo "  - Check runner status every 5 minutes"
    echo "  - Automatically restart failed pods"
    echo "  - Log status to /tmp/runner-health.log"
}

# Run main function
main "$@"
