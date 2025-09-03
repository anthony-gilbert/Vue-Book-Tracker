#!/bin/bash

# Direct GitHub Runner Fix - No Kubernetes
# This creates a stable runner that runs directly on the host

set -e

echo "🚀 Setting up Direct GitHub Runner (No K8s)"
echo "==========================================="

# Check for GitHub token
if [ -z "$GITHUB_RUNNER_TOKEN" ]; then
    echo "❌ ERROR: GITHUB_RUNNER_TOKEN environment variable is required"
    echo "Please get a fresh token from:"
    echo "https://github.com/anthony-gilbert/Vue-Book-Tracker/settings/actions/runners"
    echo "Then run: export GITHUB_RUNNER_TOKEN='your_token_here'"
    exit 1
fi

RUNNER_DIR="/opt/actions-runner"
SERVICE_NAME="github-runner"

# Function to stop and remove existing runner
cleanup_existing() {
    echo "🧹 Cleaning up existing runner..."
    
    # Stop systemd service if it exists
    sudo systemctl stop $SERVICE_NAME 2>/dev/null || true
    sudo systemctl disable $SERVICE_NAME 2>/dev/null || true
    sudo rm -f /etc/systemd/system/$SERVICE_NAME.service
    
    # Remove existing runner if configured
    if [ -d "$RUNNER_DIR" ] && [ -f "$RUNNER_DIR/config.sh" ]; then
        echo "Removing existing runner configuration..."
        cd $RUNNER_DIR
        sudo -u runner ./config.sh remove --unattended --token $GITHUB_RUNNER_TOKEN 2>/dev/null || true
    fi
    
    # Kill any running processes
    sudo pkill -f "Runner.Listener" 2>/dev/null || true
    sudo pkill -f "actions-runner" 2>/dev/null || true
    
    echo "✅ Cleanup complete"
}

# Function to create runner user
create_runner_user() {
    echo "👤 Setting up runner user..."
    if ! id "runner" &>/dev/null; then
        sudo useradd -m -s /bin/bash runner
        echo "Created runner user"
    fi
    
    # Add to docker group if docker is available
    if command -v docker &>/dev/null; then
        sudo usermod -aG docker runner 2>/dev/null || true
    fi
}

# Function to download and setup runner
setup_runner() {
    echo "📦 Setting up GitHub Actions Runner..."
    
    # Create runner directory
    sudo mkdir -p $RUNNER_DIR
    sudo chown runner:runner $RUNNER_DIR
    
    # Download latest runner if not exists
    cd $RUNNER_DIR
    if [ ! -f "run.sh" ]; then
        echo "Downloading GitHub Actions Runner..."
        RUNNER_VERSION=$(curl -s https://api.github.com/repos/actions/runner/releases/latest | grep '"tag_name"' | cut -d '"' -f 4 | sed 's/v//')
        RUNNER_URL="https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz"
        
        sudo -u runner curl -o actions-runner-linux-x64.tar.gz -L $RUNNER_URL
        sudo -u runner tar xzf actions-runner-linux-x64.tar.gz
        sudo -u runner rm actions-runner-linux-x64.tar.gz
    fi
    
    # Install dependencies
    sudo ./bin/installdependencies.sh
    
    echo "✅ Runner downloaded and dependencies installed"
}

# Function to configure runner
configure_runner() {
    echo "⚙️  Configuring runner..."
    
    cd $RUNNER_DIR
    
    # Configure runner
    sudo -u runner ./config.sh \
        --url https://github.com/anthony-gilbert/Vue-Book-Tracker \
        --token $GITHUB_RUNNER_TOKEN \
        --name "direct-vue-book-tracker-runner" \
        --labels "self-hosted,Linux,X64,vue-book-tracker,direct" \
        --work "_work" \
        --replace \
        --unattended
    
    echo "✅ Runner configured successfully"
}

# Function to create systemd service
create_service() {
    echo "🔧 Creating systemd service..."
    
    sudo tee /etc/systemd/system/$SERVICE_NAME.service > /dev/null <<EOF
[Unit]
Description=GitHub Actions Runner
After=network.target

[Service]
Type=simple
User=runner
WorkingDirectory=$RUNNER_DIR
ExecStart=$RUNNER_DIR/run.sh
Restart=always
RestartSec=5
KillMode=process
TimeoutStopSec=5min

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable $SERVICE_NAME
    
    echo "✅ Systemd service created"
}

# Function to start and monitor runner
start_runner() {
    echo "🚀 Starting GitHub Runner service..."
    
    sudo systemctl start $SERVICE_NAME
    sleep 3
    
    # Check status
    if sudo systemctl is-active --quiet $SERVICE_NAME; then
        echo "✅ Runner service is running!"
        
        echo "📊 Service status:"
        sudo systemctl status $SERVICE_NAME --no-pager -l
        
        echo ""
        echo "📋 Recent logs:"
        sudo journalctl -u $SERVICE_NAME --no-pager -n 10
        
    else
        echo "❌ Failed to start runner service"
        sudo systemctl status $SERVICE_NAME --no-pager -l
        echo ""
        echo "📋 Error logs:"
        sudo journalctl -u $SERVICE_NAME --no-pager -n 20
        exit 1
    fi
}

# Function to create monitoring script
setup_monitoring() {
    echo "📊 Setting up monitoring..."
    
    cat > /tmp/runner-monitor.sh << 'EOF'
#!/bin/bash
# Direct runner monitoring script

SERVICE_NAME="github-runner"
LOG_FILE="/var/log/github-runner-monitor.log"

# Function to log with timestamp
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | sudo tee -a $LOG_FILE
}

# Check service status
if sudo systemctl is-active --quiet $SERVICE_NAME; then
    log_message "OK: GitHub runner service is running"
else
    log_message "ERROR: GitHub runner service is not running"
    log_message "Attempting to restart service..."
    sudo systemctl restart $SERVICE_NAME
    
    sleep 5
    if sudo systemctl is-active --quiet $SERVICE_NAME; then
        log_message "OK: Service restarted successfully"
    else
        log_message "ERROR: Failed to restart service"
    fi
fi
EOF

    chmod +x /tmp/runner-monitor.sh
    sudo mv /tmp/runner-monitor.sh /usr/local/bin/runner-monitor.sh
    
    # Setup cron job for monitoring (every 2 minutes)
    (crontab -l 2>/dev/null; echo "*/2 * * * * /usr/local/bin/runner-monitor.sh") | crontab -
    
    echo "✅ Monitoring setup complete"
}

# Main execution
main() {
    cleanup_existing
    create_runner_user
    setup_runner
    configure_runner
    create_service
    start_runner
    setup_monitoring
    
    echo ""
    echo "🎉 Direct GitHub Runner setup complete!"
    echo ""
    echo "Service management commands:"
    echo "  sudo systemctl status github-runner"
    echo "  sudo systemctl restart github-runner"
    echo "  sudo journalctl -u github-runner -f"
    echo ""
    echo "Monitoring:"
    echo "  tail -f /var/log/github-runner-monitor.log"
    echo "  /usr/local/bin/runner-monitor.sh"
    echo ""
    echo "The runner is now stable and will automatically restart if it crashes."
}

# Run main function
main "$@"
