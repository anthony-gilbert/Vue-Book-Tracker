#!/bin/bash

# GitHub Runner Monitoring Script
# Monitors runner health and provides troubleshooting info

echo "🔍 GitHub Runner Status"
echo "======================"

# Check namespace
echo "📁 Namespace Status:"
kubectl get namespace github-runners 2>/dev/null || echo "❌ Namespace github-runners not found"
echo ""

# Check deployment
echo "🚀 Deployment Status:"
kubectl get deployment github-runner -n github-runners -o wide 2>/dev/null || echo "❌ Deployment not found"
echo ""

# Check pods
echo "📦 Pod Status:"
kubectl get pods -n github-runners -o wide 2>/dev/null || echo "❌ No pods found"
echo ""

# Check secret
echo "🔐 Secret Status:"
kubectl get secret github-runner-token -n github-runners 2>/dev/null && echo "✅ Token secret exists" || echo "❌ Token secret missing"
echo ""

# Resource usage
echo "💾 Node Resources:"
free -h | head -2
echo ""

# Recent logs if pod exists
POD_NAME=$(kubectl get pods -n github-runners -l app=github-runner -o jsonpath="{.items[0].metadata.name}" 2>/dev/null)
if [ ! -z "$POD_NAME" ]; then
    echo "📋 Recent Logs from $POD_NAME:"
    kubectl logs $POD_NAME -n github-runners --tail=10 2>/dev/null || echo "❌ Cannot get logs"
else
    echo "📋 No running pods to show logs from"
fi
echo ""

# Troubleshooting hints
echo "🛠️  Troubleshooting Hints:"
echo "- If pod is CrashLoopBackOff, check if token is expired"
echo "- If ResourceQuota issues, reduce resource limits in deployment.yaml"
echo "- Get fresh token from: https://github.com/anthony-gilbert/Vue-Book-Tracker/settings/actions/runners"
echo "- Restart with: ./restart-runner.sh"
