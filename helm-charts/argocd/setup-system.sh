#!/bin/bash

# System preparation script for ArgoCD deployment
# This ensures the system has enough resources and proper configuration

set -e

echo "🚀 Setting up system for ArgoCD deployment..."

# Check available memory
AVAILABLE_MEM=$(free -m | awk 'NR==2{printf "%.0f", $7}')
echo "💾 Available memory: ${AVAILABLE_MEM}MB"

if [ "$AVAILABLE_MEM" -lt 200 ]; then
    echo "⚠️  Low memory detected. Cleaning up system..."
    
    # Clean up APT cache
    apt-get autoclean -y
    apt-get autoremove -y
    
    # Clean up Docker/containerd if needed
    if command -v k3s >/dev/null 2>&1; then
        echo "🧹 Cleaning up container images..."
        k3s crictl images prune || true
    fi
    
    AVAILABLE_MEM_AFTER=$(free -m | awk 'NR==2{printf "%.0f", $7}')
    echo "💾 Memory after cleanup: ${AVAILABLE_MEM_AFTER}MB"
fi

# Check disk space
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
echo "💿 Disk usage: ${DISK_USAGE}%"

if [ "$DISK_USAGE" -gt 85 ]; then
    echo "⚠️  High disk usage detected. Cleaning up..."
    
    # Clean up logs older than 7 days
    find /var/log -name "*.log" -mtime +7 -delete || true
    find /var/log -name "*.gz" -mtime +7 -delete || true
    
    # Clean up temporary files
    rm -rf /tmp/* || true
    
    DISK_USAGE_AFTER=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    echo "💿 Disk usage after cleanup: ${DISK_USAGE_AFTER}%"
fi

echo "✅ System preparation completed"
