# GitHub Actions Self-Hosted Runner for Kubernetes

This directory contains all the necessary files to deploy a GitHub Actions self-hosted runner in your Kubernetes cluster.

## 🚀 Quick Start

### Prerequisites
- Kubernetes cluster access (kubectl configured)
- GitHub repository admin access
- Registration token from GitHub (expires in 1 hour)

### 1. Get GitHub Registration Token

1. Go to your repository: https://github.com/anthony-gilbert/Vue-Book-Tracker/settings/actions/runners
2. Click **"New self-hosted runner"**
3. Copy the registration token (starts with 'A' and is ~29 characters long)

### 2. Deploy the Runner

```bash
# Navigate to the runner directory
cd github-runner-k8s

# Run the setup script
./setup.sh

# Or provide the token as environment variable
GITHUB_RUNNER_TOKEN="YOUR_TOKEN_HERE" ./setup.sh
```

### 3. Verify Deployment

```bash
# Check runner status
kubectl get pods -n github-runners

# View runner logs
kubectl logs -n github-runners -l app=github-runner
```

## 📁 Files Overview

- **`namespace.yaml`** - Creates the github-runners namespace
- **`secret-template.yaml`** - Template for storing the GitHub token
- **`deployment.yaml`** - Main deployment configuration for the runner
- **`setup.sh`** - Automated setup script
- **`cleanup.sh`** - Script to remove the runner
- **`scale.sh`** - Script to scale the number of runner instances

## 🔧 Management Commands

### Scale Runners
```bash
# Scale to 3 runner instances
./scale.sh 3

# Scale down to 1 instance
./scale.sh 1

# Scale to 0 (stop all runners)
./scale.sh 0
```

### View Logs
```bash
# View recent logs
kubectl logs -n github-runners -l app=github-runner --tail=20

# Follow logs in real-time
kubectl logs -n github-runners -l app=github-runner -f
```

### Check Status
```bash
# Check pods
kubectl get pods -n github-runners

# Check deployment
kubectl get deployment github-runner -n github-runners

# Describe deployment for troubleshooting
kubectl describe deployment github-runner -n github-runners
```

### Cleanup
```bash
# Remove the runner deployment
./cleanup.sh
```

## 📝 Using in GitHub Actions

Once deployed, you can use the self-hosted runner in your workflow files:

```yaml
name: CI/CD Pipeline
on: [push, pull_request]

jobs:
  build:
    runs-on: self-hosted  # This will use your Kubernetes runner
    steps:
    - uses: actions/checkout@v3
    - name: Build application
      run: |
        npm install
        npm run build
```

You can also target specific labels:

```yaml
jobs:
  build:
    runs-on: [self-hosted, kubernetes, vue-book-tracker]
    steps:
    - name: Build on Kubernetes
      run: echo "Running on Kubernetes runner"
```

## 🔄 Re-deployment Process

When you need to redeploy (e.g., after infrastructure changes):

1. **Get a new registration token** (the old one expires in 1 hour)
   - Go to GitHub repository settings → Actions → Runners
   - Click "New self-hosted runner"
   - Copy the new token

2. **Clean up existing deployment** (optional)
   ```bash
   ./cleanup.sh
   ```

3. **Deploy with new token**
   ```bash
   GITHUB_RUNNER_TOKEN="NEW_TOKEN_HERE" ./setup.sh
   ```

## 🛠️ Customization

### Change Repository
Edit the `RUNNER_REPO` environment variable in `deployment.yaml`:
```yaml
- name: RUNNER_REPO
  value: "your-username/your-repository"
```

### Add Custom Labels
Edit the `RUNNER_LABELS` environment variable in `deployment.yaml`:
```yaml
- name: RUNNER_LABELS
  value: "kubernetes,self-hosted,custom-label,production"
```

### Resource Limits
Adjust CPU and memory limits in `deployment.yaml`:
```yaml
resources:
  requests:
    memory: "512Mi"
    cpu: "500m"
  limits:
    memory: "1Gi"
    cpu: "1000m"
```

## 🐛 Troubleshooting

### Runner Not Appearing in GitHub
1. Check pod logs: `kubectl logs -n github-runners -l app=github-runner`
2. Verify the token is correct and not expired
3. Ensure the repository name is correct

### Pod Stuck in Pending State
1. Check node resources: `kubectl describe pod -n github-runners`
2. Verify the namespace exists: `kubectl get ns github-runners`

### Runner Registration Failed
1. Get a fresh registration token from GitHub
2. Update the secret: 
   ```bash
   kubectl delete secret github-runner-token -n github-runners
   GITHUB_RUNNER_TOKEN="NEW_TOKEN" ./setup.sh
   ```

### Multiple Runners with Same Name
This is normal when scaling > 1. GitHub automatically appends numbers to runner names.

## 🔒 Security Considerations

- Registration tokens expire in 1 hour - store them securely
- The runner has access to your repository code
- Consider using GitHub Apps for long-term deployments
- Monitor runner resource usage to prevent abuse

## 📚 Additional Resources

- [GitHub Actions Self-hosted Runners Documentation](https://docs.github.com/en/actions/hosting-your-own-runners)
- [Kubernetes Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [Actions Runner Controller](https://github.com/actions-runner-controller/actions-runner-controller) (for advanced setups)
