# k3d Installation Guide for Ubuntu 24.04

## Overview
k3d is a lightweight wrapper to run k3s (Rancher Lab's minimal Kubernetes distribution) in Docker. It makes it easy to create single-node and multi-node k3s clusters in Docker for local development and testing.

## Prerequisites

Before installing k3d, ensure your Ubuntu 24.04 system has Docker installed and running.

### Step 1: Update System Packages
```bash
sudo apt update && sudo apt upgrade -y
```
**Note:** This updates the package list and upgrades installed packages to their latest versions to ensure compatibility.

### Step 2: Install Docker (if not already installed)
```bash
# Install Docker dependencies
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index and install Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Add current user to docker group
sudo usermod -aG docker $USER

# Start and enable Docker service
sudo systemctl start docker
sudo systemctl enable docker
```
**Note:** Adding your user to the docker group allows running Docker commands without sudo. You'll need to log out and back in for this change to take effect.

### Step 3: Verify Docker Installation
```bash
docker --version
docker run hello-world
```
**Note:** This confirms Docker is properly installed and can run containers.

## k3d Installation

### Step 4: Download and Install k3d Using curl
```bash
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
```
**Note:** This command downloads and executes the official k3d installation script. The script automatically detects your system architecture and installs the appropriate k3d binary to `/usr/local/bin/`.

**Alternative manual installation:**
```bash
# Download k3d binary directly (replace VERSION with desired version, e.g., v5.6.0)
curl -Lo k3d https://github.com/k3d-io/k3d/releases/latest/download/k3d-linux-amd64

# Make it executable
chmod +x k3d

# Move to PATH
sudo mv k3d /usr/local/bin/
```

### Step 5: Verify k3d Installation
```bash
k3d version
```
**Note:** This displays the installed k3d version and confirms the installation was successful.

### Step 6: Install kubectl (Kubernetes CLI)
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```
**Note:** kubectl is the command-line tool for interacting with Kubernetes clusters. k3d clusters require kubectl to manage deployments and resources.

### Step 7: Verify kubectl Installation
```bash
kubectl version --client
```

## Creating Your First k3d Cluster

### Step 8: Create a Basic k3d Cluster
```bash
k3d cluster create mycluster
```
**Note:** This creates a single-node k3s cluster named "mycluster" running in Docker containers. The cluster includes a server node and a load balancer.

### Step 9: Verify Cluster Status
```bash
k3d cluster list
kubectl cluster-info
kubectl get nodes
```
**Note:** These commands confirm your cluster is running and accessible via kubectl.

## Configuration and Testing

### Step 10: Configure kubectl Context
```bash
k3d kubeconfig merge mycluster --kubeconfig-switch-context
```
**Note:** This updates your kubeconfig file and switches the current context to your new k3d cluster.

### Step 11: Test the Cluster
```bash
# Deploy a test application
kubectl create deployment nginx --image=nginx

# Expose the deployment
kubectl expose deployment nginx --port=80 --type=NodePort

# Check the status
kubectl get pods
kubectl get services
```
**Note:** This deploys an nginx web server to test that your cluster can run workloads successfully.

---

# k3d Command Cheatsheet

## Cluster Management

| Command | Description |
|---------|-------------|
| `k3d cluster create <name>` | Create a new k3d cluster |
| `k3d cluster create <name> --agents 3` | Create cluster with 3 agent nodes |
| `k3d cluster create <name> -p "8080:80@loadbalancer"` | Create cluster with port mapping |
| `k3d cluster list` | List all k3d clusters |
| `k3d cluster start <name>` | Start a stopped cluster |
| `k3d cluster stop <name>` | Stop a running cluster |
| `k3d cluster delete <name>` | Delete a cluster completely |
| `k3d cluster delete --all` | Delete all clusters |

## Node Management

| Command | Description |
|---------|-------------|
| `k3d node list` | List all nodes across clusters |
| `k3d node create <name>` | Create a new node |
| `k3d node start <name>` | Start a stopped node |
| `k3d node stop <name>` | Stop a running node |
| `k3d node delete <name>` | Delete a node |

## Configuration Management

| Command | Description |
|---------|-------------|
| `k3d kubeconfig get <name>` | Get kubeconfig for specific cluster |
| `k3d kubeconfig merge <name>` | Merge cluster kubeconfig with default |
| `k3d kubeconfig merge <name> --kubeconfig-switch-context` | Merge and switch context |

## Registry Management

| Command | Description |
|---------|-------------|
| `k3d registry create <name>` | Create a local Docker registry |
| `k3d registry list` | List local registries |
| `k3d registry delete <name>` | Delete a local registry |

## Image Management

| Command | Description |
|---------|-------------|
| `k3d image import <image> -c <cluster>` | Import Docker image into cluster |
| `k3d image list <cluster>` | List images in cluster |

## Common Cluster Creation Examples

### Basic single-node cluster
```bash
k3d cluster create dev
```

### Multi-node cluster with custom configuration
```bash
k3d cluster create production \
  --agents 3 \
  --port 8080:80@loadbalancer \
  --port 8443:443@loadbalancer \
  --volume /tmp/k3d:/tmp/k3d@all
```

### Cluster with registry
```bash
k3d cluster create dev-with-registry \
  --registry-create \
  --registry-use k3d-registry:5000
```

## Troubleshooting Commands

| Command | Description |
|---------|-------------|
| `k3d cluster list` | Check cluster status |
| `docker ps -a` | See all k3d containers |
| `k3d cluster delete <name> && k3d cluster create <name>` | Reset cluster |
| `kubectl get nodes -o wide` | Detailed node information |
| `kubectl describe node <node-name>` | Node diagnostics |

## Useful kubectl Commands for k3d

| Command | Description |
|---------|-------------|
| `kubectl get pods --all-namespaces` | List all pods in cluster |
| `kubectl get services` | List all services |
| `kubectl cluster-info` | Display cluster information |
| `kubectl config current-context` | Show current context |
| `kubectl config get-contexts` | List all contexts |

## Tips and Best Practices

1. **Resource Management**: k3d clusters run in Docker containers, so they consume system resources. Stop unused clusters with `k3d cluster stop <name>`.

2. **Port Mapping**: Use port mapping during cluster creation to expose services: `k3d cluster create <name> -p "8080:80@loadbalancer"`

3. **Persistent Storage**: Mount host directories for persistent data: `--volume /host/path:/container/path@all`

4. **Development Workflow**: Create separate clusters for different projects to avoid conflicts.

5. **Cleanup**: Regularly clean up unused clusters and images to free disk space.

## Next Steps

- Explore Kubernetes concepts with your k3d cluster
- Deploy applications using Helm charts
- Set up CI/CD pipelines using k3d for testing
- Learn about Kubernetes networking and storage