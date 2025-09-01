#!/bin/bash

# Permanent ArgoCD port-forward service
# This ensures ArgoCD is always accessible via port 8081

echo "Starting ArgoCD port-forward service..."

# Kill any existing port-forwards
pkill -f "kubectl port-forward.*argocd-server" || true
sleep 2

# Start port-forward in background
kubectl port-forward svc/argocd-server -n argocd 8081:80 > /var/log/argocd-portforward.log 2>&1 &
FORWARD_PID=$!

echo "ArgoCD port-forward started with PID: $FORWARD_PID"
echo "Logs: /var/log/argocd-portforward.log"
echo "ArgoCD accessible at: http://localhost:8081"

# Verify it's working
sleep 5
if curl -s http://localhost:8081 > /dev/null; then
    echo "✅ ArgoCD port-forward is working"
    echo "✅ https://argocd.booktracker.dev should now be accessible"
else
    echo "❌ ArgoCD port-forward failed"
    exit 1
fi

echo $FORWARD_PID > /tmp/argocd-portforward.pid
