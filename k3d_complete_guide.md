# Complete K3d Documentation Guide

## Table of Contents
1. [Introduction](#introduction)
2. [Installation](#installation)
3. [Basic Concepts](#basic-concepts)
4. [Cluster Management](#cluster-management)
5. [Node Management](#node-management)
6. [Networking and Load Balancing](#networking-and-load-balancing)
7. [Storage and Volumes](#storage-and-volumes)
8. [Registry Management](#registry-management)
9. [Image Management](#image-management)
10. [Configuration Files](#configuration-files)
11. [Multi-Cluster Workflows](#multi-cluster-workflows)
12. [Troubleshooting](#troubleshooting)
13. [Best Practices](#best-practices)
14. [Advanced Scenarios](#advanced-scenarios)
15. [k3d vs kubectl Reference](#k3d-vs-kubectl-reference)
16. [Common Workflows](#common-workflows)
17. [Cheat Sheet](#cheat-sheet)

---

## Introduction

K3d is a lightweight wrapper to run k3s (Rancher Lab's minimal Kubernetes distribution) in Docker. It makes it very easy to create single- and multi-node k3s clusters in Docker for local development on Kubernetes.

### What is k3d?
- **k3d** = k3s in Docker
- **k3s** = Lightweight Kubernetes distribution
- **Docker** = Container runtime

### Key Benefits
- ⚡ **Fast**: Clusters start in seconds
- 🐳 **Docker-native**: Runs entirely in Docker containers
- 🔧 **Easy**: Simple commands for complex setups
- 🏗️ **Multi-cluster**: Run multiple isolated clusters
- 📦 **Lightweight**: Minimal resource usage
- 🚀 **CI/CD Ready**: Perfect for testing pipelines

---

## Installation

### Prerequisites
- Docker installed and running
- kubectl (Kubernetes CLI)

### Install k3d

#### macOS
```bash
# Using Homebrew
brew install k3d

# Using curl
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
```

#### Linux
```bash
# Using curl
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Using wget
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
```

#### Windows
```powershell
# Using Chocolatey
choco install k3d

# Using Scoop
scoop install k3d

# Manual download from GitHub releases
# https://github.com/k3d-io/k3d/releases
```

### Verify Installation
```bash
k3d version
docker version
kubectl version --client
```

---

## Basic Concepts

### Architecture
```
┌─────────────────────────────────────────┐
│               Host System               │
│  ┌─────────────────────────────────────┐│
│  │             Docker              │ │
│  │  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐│ │
│  │  │Node1│ │Node2│ │Node3│ │ LB  ││ │
│  │  │     │ │     │ │     │ │     ││ │
│  │  └─────┘ └─────┘ └─────┘ └─────┘│ │
│  └─────────────────────────────────────┘│
└─────────────────────────────────────────┘
```

### Key Components
- **Server Nodes**: Control plane nodes (masters)
- **Agent Nodes**: Worker nodes
- **Load Balancer**: Routes traffic to the cluster
- **Registry**: Optional container registry

### Node Types
- **server**: Control plane node (etcd, API server, scheduler)
- **agent**: Worker node (kubelet, kube-proxy)
- **loadbalancer**: Load balancer container

---

## Cluster Management

### Creating Clusters

#### Basic Cluster
```bash
# Simplest cluster (1 server node)
k3d cluster create

# Named cluster
k3d cluster create mycluster

# Cluster with custom name
k3d cluster create my-development-cluster
```

#### Cluster with Multiple Nodes
```bash
# 1 server + 3 agents
k3d cluster create multinode --agents 3

# 3 servers + 2 agents (HA setup)
k3d cluster create ha-cluster --servers 3 --agents 2

# Specific server and agent count
k3d cluster create production --servers 1 --agents 5
```

#### Advanced Cluster Creation
```bash
# Full-featured development cluster
k3d cluster create dev-env \
  --agents 3 \
  --port "8080:80@loadbalancer" \
  --port "8443:443@loadbalancer" \
  --port "30000-32767:30000-32767@server:0" \
  --api-port 6443 \
  --volume "/tmp/k3d-storage:/storage@all" \
  --registry-create dev-registry:5000

# Cluster with specific k3s version
k3d cluster create legacy \
  --image rancher/k3s:v1.24.8-k3s1 \
  --agents 2

# Cluster with custom subnet
k3d cluster create network-test \
  --subnet 172.20.0.0/16 \
  --agents 2
```

### Listing and Inspecting Clusters
```bash
# List all clusters
k3d cluster list

# Detailed cluster information
k3d cluster list --output json

# Get specific cluster info
k3d cluster get mycluster

# Show cluster configuration
k3d cluster get mycluster --output yaml
```

### Starting and Stopping Clusters
```bash
# Start cluster
k3d cluster start mycluster

# Stop cluster (preserves data)
k3d cluster stop mycluster

# Start all clusters
k3d cluster start --all

# Stop all clusters  
k3d cluster stop --all
```

### Deleting Clusters
```bash
# Delete specific cluster
k3d cluster delete mycluster

# Delete multiple clusters
k3d cluster delete cluster1 cluster2 cluster3

# Delete all clusters
k3d cluster delete --all

# Force delete (if normal delete fails)
docker rm -f $(docker ps -aq --filter "label=app=k3d")
```

---

## Node Management

### Adding Nodes

#### Add Agent Nodes
```bash
# Add single agent to existing cluster
k3d node create new-agent --cluster mycluster --role agent

# Add multiple agents
k3d node create agent-1 agent-2 agent-3 \
  --cluster mycluster \
  --role agent

# Add agent with specific image
k3d node create custom-agent \
  --cluster mycluster \
  --role agent \
  --image rancher/k3s:v1.25.0-k3s1
```

#### Add Server Nodes
```bash
# Add server node (for HA)
k3d node create new-server \
  --cluster mycluster \
  --role server

# Add multiple servers
k3d node create server-2 server-3 \
  --cluster mycluster \
  --role server
```

### Listing and Inspecting Nodes
```bash
# List all nodes across clusters
k3d node list

# List nodes in specific cluster
k3d node list mycluster

# Get detailed node info
k3d node get node-name

# List nodes with labels
k3d node list --output json | jq '.[].labels'
```

### Node Operations
```bash
# Start specific node
k3d node start node-name

# Stop specific node
k3d node stop node-name

# Delete specific node
k3d node delete node-name

# Delete multiple nodes
k3d node delete node-1 node-2 node-3

# Get node logs
docker logs k3d-mycluster-agent-0
```

### Node Troubleshooting
```bash
# Check node status in Kubernetes
kubectl get nodes

# Describe node
kubectl describe node k3d-mycluster-agent-0

# Shell into node
docker exec -it k3d-mycluster-server-0 /bin/sh

# Check node resource usage
kubectl top nodes

# Check node conditions
kubectl get nodes -o wide
```

---

## Networking and Load Balancing

### Port Mapping
```bash
# Map load balancer ports
k3d cluster create web-app \
  --port "8080:80@loadbalancer" \
  --port "8443:443@loadbalancer"

# Map NodePort range
k3d cluster create nodeport-cluster \
  --port "30000-32767:30000-32767@server:0"

# Map specific service ports
k3d cluster create api-cluster \
  --port "3000:3000@loadbalancer" \
  --port "5432:5432@loadbalancer"

# Map multiple ports
k3d cluster create multi-service \
  --port "8080:80@loadbalancer" \
  --port "8443:443@loadbalancer" \
  --port "9090:9090@loadbalancer" \
  --port "3000:3000@loadbalancer"
```

### Load Balancer Configuration
```bash
# Cluster without load balancer
k3d cluster create no-lb --no-lb

# Custom load balancer configuration
k3d cluster create custom-lb \
  --port "80:80@loadbalancer" \
  --lb-config-override /path/to/lb-config.yaml
```

### Network Settings
```bash
# Custom Docker network
docker network create k3d-network
k3d cluster create networked \
  --network k3d-network \
  --subnet 172.28.0.0/16

# Connect to existing network
k3d cluster create existing-net \
  --network existing-docker-network

# Multiple networks
k3d cluster create multi-net \
  --network net1 \
  --network net2
```

### Service Examples
```yaml
# service-nodeport.yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service-nodeport
spec:
  type: NodePort
  selector:
    app: my-app
  ports:
    - port: 80
      targetPort: 8080
      nodePort: 30080

---
# service-loadbalancer.yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service-lb
spec:
  type: LoadBalancer
  selector:
    app: my-app
  ports:
    - port: 80
      targetPort: 8080
```

---

## Storage and Volumes

### Volume Mounting
```bash
# Mount host directory
k3d cluster create dev-with-storage \
  --volume "/host/path:/container/path@all"

# Mount to specific nodes
k3d cluster create selective-mount \
  --volume "/host/data:/data@server:0" \
  --volume "/host/logs:/logs@agent:*"

# Multiple volume mounts
k3d cluster create multi-volume \
  --volume "/host/app:/app@all" \
  --volume "/host/data:/data@server:*" \
  --volume "/host/logs:/var/log@agent:*"

# Current directory mount (development)
k3d cluster create local-dev \
  --volume "$PWD:/workspace@all" \
  --agents 2
```

### Volume Mount Syntax
```bash
# Syntax: --volume "[SOURCE:]DEST[@NODEFILTER]"

# Examples:
--volume "/host/path:/container/path@all"           # All nodes
--volume "/host/path:/container/path@server:0"      # First server
--volume "/host/path:/container/path@agent:*"       # All agents
--volume "/host/path:/container/path@server:0,1"    # First two servers
--volume "volume-name:/path@all"                    # Named volume
```

### Persistent Volume Examples
```yaml
# pv-hostpath.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-storage
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/data"
  storageClassName: local-storage

---
# pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-claim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: local-storage
```

### Storage Classes
```bash
# Check available storage classes
kubectl get storageclass

# Default k3s storage class
kubectl get storageclass local-path -o yaml
```

---

## Registry Management

### Creating Registries
```bash
# Create standalone registry
k3d registry create myregistry --port 5000

# Create registry with cluster
k3d cluster create dev \
  --registry-create dev-registry:5000

# Create cluster using existing registry
k3d registry create shared-registry --port 5001
k3d cluster create app1 --registry-use k3d-shared-registry:5001
k3d cluster create app2 --registry-use k3d-shared-registry:5001
```

### Registry Operations
```bash
# List registries
k3d registry list

# Delete registry
k3d registry delete myregistry

# Connect existing registry to cluster
k3d cluster create existing-reg \
  --registry-use localhost:5000
```

### Using Registries
```bash
# Tag and push to k3d registry
docker tag myapp:latest localhost:5000/myapp:latest
docker push localhost:5000/myapp:latest

# Deploy from local registry
kubectl create deployment myapp --image=localhost:5000/myapp:latest

# Registry configuration file
# ~/.k3d/registries.yaml
mirrors:
  "localhost:5000":
    endpoint:
      - "http://k3d-myregistry:5000"
```

---

## Image Management

### Importing Images
```bash
# Import single image
k3d image import myapp:latest --cluster mycluster

# Import multiple images
k3d image import \
  nginx:latest \
  redis:alpine \
  postgres:13 \
  --cluster mycluster

# Import from tar file
docker save myapp:latest -o myapp.tar
k3d image import myapp.tar --cluster mycluster

# Import to all clusters
k3d image import myapp:latest --clusters mycluster,testcluster
```

### Image Best Practices
```bash
# Build and import workflow
docker build -t myapp:dev .
k3d image import myapp:dev --cluster dev

# Multi-stage development
docker build -t myapp:test . --target test
docker build -t myapp:prod . --target production
k3d image import myapp:test --cluster test
k3d image import myapp:prod --cluster staging
```

---

## Configuration Files

### Cluster Configuration File
```yaml
# k3d-config.yaml
apiVersion: k3d.io/v1alpha4
kind: Simple
metadata:
  name: development-cluster
servers: 1
agents: 3
kubeAPI:
  host: "localhost"
  hostIP: "127.0.0.1"
  hostPort: "6445"
image: rancher/k3s:v1.25.0-k3s1
network: k3d-development
subnet: "172.28.0.0/16"
token: my-super-secret-token
volumes:
  - volume: /host/app:/app
    nodeFilters:
      - all
  - volume: /host/data:/data
    nodeFilters:
      - server:*
ports:
  - port: 8080:80
    nodeFilters:
      - loadbalancer
  - port: 8443:443
    nodeFilters:
      - loadbalancer
options:
  k3d:
    wait: true
    timeout: "300s"
    disableLoadbalancer: false
    disableImageVolume: false
  k3s:
    extraArgs:
      - arg: --disable=traefik
        nodeFilters:
          - server:*
      - arg: --disable=metrics-server
        nodeFilters:
          - server:*
  kubeconfig:
    updateDefaultKubeconfig: true
    switchCurrentContext: true
registries:
  create:
    name: dev-registry
    host: "localhost"
    hostPort: "5000"
  config: |
    mirrors:
      "localhost:5000":
        endpoint:
          - http://k3d-dev-registry:5000
```

### Using Configuration Files
```bash
# Create cluster from config
k3d cluster create --config k3d-config.yaml

# Generate config from existing cluster
k3d cluster get mycluster --output yaml > mycluster-config.yaml

# Validate configuration
k3d cluster create --config k3d-config.yaml --dry-run
```

### Environment-Specific Configs
```bash
# Development config
# k3d-dev.yaml - lightweight, fast startup

# Testing config  
# k3d-test.yaml - multiple nodes, persistent volumes

# Staging config
# k3d-staging.yaml - production-like setup
```

---

## Multi-Cluster Workflows

### Creating Multiple Environments
```bash
# Development environment
k3d cluster create dev \
  --agents 2 \
  --port "8080:80@loadbalancer" \
  --volume "$PWD:/workspace@all"

# Testing environment
k3d cluster create test \
  --agents 3 \
  --port "9080:80@loadbalancer" \
  --image rancher/k3s:v1.24.8-k3s1

# Staging environment
k3d cluster create staging \
  --servers 3 \
  --agents 3 \
  --port "10080:80@loadbalancer"

# Production-like environment
k3d cluster create prod-like \
  --servers 3 \
  --agents 5 \
  --port "11080:80@loadbalancer"
```

### Context Management
```bash
# List available contexts
kubectl config get-contexts

# Switch between environments
kubectl config use-context k3d-dev
kubectl config use-context k3d-test
kubectl config use-context k3d-staging

# Create aliases for quick switching
alias k3dev='kubectl config use-context k3d-dev'
alias k3test='kubectl config use-context k3d-test'
alias k3stage='kubectl config use-context k3d-staging'

# Current context
kubectl config current-context

# Rename context
kubectl config rename-context k3d-dev k3d-development
```

### Cross-Cluster Operations
```bash
# Deploy to multiple clusters
for cluster in dev test staging; do
  kubectl config use-context k3d-$cluster
  kubectl apply -f deployment.yaml
done

# Check status across clusters
for cluster in dev test staging; do
  echo "=== Cluster: $cluster ==="
  kubectl config use-context k3d-$cluster
  kubectl get pods
done

# Synchronized deployments
kubectl config use-context k3d-dev
kubectl apply -f manifests/
kubectl config use-context k3d-test  
kubectl apply -f manifests/
```

---

## Troubleshooting

### Common Issues and Solutions

#### Cluster Won't Start
```bash
# Check Docker status
docker ps
systemctl status docker  # Linux
brew services list | grep docker  # macOS

# Check available resources
docker system df
docker system prune -f

# Remove conflicting containers
docker rm -f $(docker ps -aq --filter "label=app=k3d")

# Reset Docker network
docker network prune -f
```

#### Port Conflicts
```bash
# Check port usage
netstat -tulpn | grep :8080  # Linux
lsof -i :8080  # macOS

# Use different ports
k3d cluster create dev --port "8081:80@loadbalancer"

# Find available ports
for port in {8080..8090}; do
  nc -z localhost $port || echo "Port $port is available"
done
```

#### Kubeconfig Issues
```bash
# Regenerate kubeconfig
k3d kubeconfig merge mycluster --kubeconfig-merge-default --kubeconfig-switch-context

# Manual kubeconfig setup
k3d kubeconfig get mycluster > ~/.kube/k3d-mycluster
export KUBECONFIG=~/.kube/k3d-mycluster

# Fix permissions
chmod 600 ~/.kube/config
```

#### Node Issues
```bash
# Check node status
kubectl get nodes -o wide

# Node not ready - check logs
docker logs k3d-mycluster-server-0
docker logs k3d-mycluster-agent-0

# Restart problematic node
k3d node stop node-name
k3d node start node-name

# Remove and recreate node
k3d node delete problematic-node
k3d node create new-node --cluster mycluster --role agent
```

### Debug Commands
```bash
# Cluster information
kubectl cluster-info
kubectl cluster-info dump

# Check all resources
kubectl get all --all-namespaces

# System events
kubectl get events --sort-by='.lastTimestamp'

# Node diagnostics
kubectl describe nodes
kubectl top nodes  # Requires metrics-server

# Pod diagnostics
kubectl describe pod pod-name
kubectl logs pod-name -f
kubectl exec -it pod-name -- /bin/sh
```

### Performance Troubleshooting
```bash
# Check resource usage
docker stats

# k3d specific containers
docker ps --filter "label=app=k3d"

# Memory and CPU usage per node
kubectl top nodes
kubectl top pods --all-namespaces

# Disk usage
df -h
docker system df
```

### Log Analysis
```bash
# k3d cluster logs
docker logs k3d-mycluster-server-0
docker logs k3d-mycluster-agent-0

# Follow logs in real-time
docker logs -f k3d-mycluster-server-0

# Application logs
kubectl logs deployment/myapp
kubectl logs -f pod/myapp-pod

# Previous container logs
kubectl logs pod/myapp-pod --previous
```

---

## Best Practices

### Development Workflow
```bash
# 1. Create development cluster with volumes
k3d cluster create dev \
  --agents 2 \
  --port "8080:80@loadbalancer" \
  --port "8443:443@loadbalancer" \
  --volume "$PWD:/workspace@all" \
  --registry-create dev-registry:5000

# 2. Build and import images
docker build -t myapp:dev .
k3d image import myapp:dev --cluster dev

# 3. Deploy applications
kubectl apply -f k8s/

# 4. Hot reload development (with volumes)
# Edit code -> automatic reload in containers
```

### Resource Management
```bash
# Appropriate cluster sizing
# Development: 1 server, 1-2 agents
# Testing: 1 server, 2-3 agents  
# Staging: 3 servers, 3-5 agents

# Memory considerations
# Each node ~100-200MB base memory
# Plan for application memory on top

# CPU considerations
# k3s is lightweight, but plan for workloads
```

### Naming Conventions
```bash
# Descriptive cluster names
k3d cluster create frontend-dev
k3d cluster create api-test
k3d cluster create full-stack-staging

# Environment prefixes
k3d cluster create dev-microservice-a
k3d cluster create test-microservice-a
k3d cluster create stage-microservice-a

# Feature-based naming
k3d cluster create feature-auth-system
k3d cluster create feature-payment-gateway
```

### Security Practices
```bash
# Use specific k3s versions
k3d cluster create secure \
  --image rancher/k3s:v1.25.4-k3s1

# Disable unnecessary components
k3d cluster create minimal \
  --k3s-arg '--disable=traefik@server:*' \
  --k3s-arg '--disable=metrics-server@server:*'

# Custom tokens for production-like testing
k3d cluster create prod-test \
  --token my-super-secure-token-123
```

### Performance Optimization
```bash
# Faster startup with image caching
k3d cluster create fast \
  --agents 2 \
  --wait \
  --timeout 300s

# Optimize for CI/CD
k3d cluster create ci \
  --agents 1 \
  --no-lb \
  --image rancher/k3s:latest \
  --wait

# Resource limits for laptops
k3d cluster create laptop \
  --agents 1 \
  --memory 1g \
  --cpus 1
```

---

## Advanced Scenarios

### High Availability Setup
```bash
# 3-node control plane cluster
k3d cluster create ha-cluster \
  --servers 3 \
  --agents 5 \
  --server-arg '--cluster-init@server:0' \
  --server-arg '--disable=traefik@server:*' \
  --port "6443:6443@loadbalancer" \
  --port "80:80@loadbalancer" \
  --port "443:443@loadbalancer"

# Verify HA setup
kubectl get nodes
kubectl get pods -n kube-system
```

### GPU Support
```bash
# Enable GPU support (requires NVIDIA Docker runtime)
k3d cluster create gpu-cluster \
  --gpus all \
  --image rancher/k3s:latest

# Deploy GPU workload
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: gpu-test
spec:
  containers:
  - name: gpu-container
    image: nvidia/cuda:11.0-runtime-ubuntu18.04
    resources:
      limits:
        nvidia.com/gpu: 1
    command: ["nvidia-smi"]
EOF
```

### Custom CNI
```bash
# Disable default CNI and install custom
k3d cluster create custom-cni \
  --k3s-arg '--flannel-backend=none@server:*' \
  --k3s-arg '--disable-network-policy@server:*'

# Install Calico
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```

### External Database
```bash
# k3s with external database
k3d cluster create external-db \
  --k3s-arg '--datastore-endpoint=postgres://user:pass@host:5432/k3s@server:*'
```

### Monitoring Setup
```bash
# Cluster with monitoring ports
k3d cluster create monitoring \
  --agents 3 \
  --port "3000:3000@loadbalancer" \
  --port "9090:9090@loadbalancer" \
  --port "9093:9093@loadbalancer"

# Deploy monitoring stack
kubectl apply -f monitoring/
```

---

## k3d vs kubectl Reference

### Command Comparison Matrix

| Operation | k3d Command | kubectl Command | Notes |
|-----------|-------------|-----------------|-------|
| **Infrastructure** | | | |
| Create cluster | `k3d cluster create dev` | ❌ | k3d only |
| Delete cluster | `k3d cluster delete dev` | ❌ | k3d only |
| List clusters | `k3d cluster list` | `kubectl config get-contexts` | Different views |
| Start cluster | `k3d cluster start dev` | ❌ | k3d only |
| Stop cluster | `k3d cluster stop dev` | ❌ | k3d only |
| Add node | `k3d node create worker` | ❌ | k3d only |
| Remove node | `k3d node delete worker` | `kubectl delete node worker` | Different purposes |
| **Applications** | | | |
| Deploy app | ❌ | `kubectl apply -f app.yaml` | kubectl only |
| List pods | ❌ | `kubectl get pods` | kubectl only |
| Scale app | ❌ | `kubectl scale deployment app` | kubectl only |
| Get logs | ❌ | `kubectl logs pod-name` | kubectl only |
| **Images** | | | |
| Import image | `k3d image import myapp:latest` | ❌ | k3d only |
| Pull image | ❌ | `kubectl create deployment app --image=myapp` | kubectl only |
| **Configuration** | | | |
| Get kubeconfig | `k3d kubeconfig get dev` | `kubectl config view` | Different purposes |
| Switch context | ❌ | `kubectl config use-context k3d-dev` | kubectl only |
| **Debugging** | | | |
| Cluster info | ❌ | `kubectl cluster-info` | kubectl only |
| Describe resource | ❌ | `kubectl describe pod myapp` | kubectl only |
| Port forward | ❌ | `kubectl port-forward svc/app 8080:80` | kubectl only |

### Workflow Integration
```bash
# Complete development workflow
# Step 1: k3d creates infrastructure
k3d cluster create myapp --agents 2 --port "8080:80@loadbalancer"

# Step 2: kubectl manages applications
kubectl apply -f deployment.yaml
kubectl get pods
kubectl logs deployment/myapp

# Step 3: k3d manages cluster lifecycle
k3d cluster stop myapp  # When done
k3d cluster start myapp # Resume work
k3d cluster delete myapp # Clean up
```

---

## Common Workflows

### Frontend Development
```bash
# React/Vue/Angular development setup
k3d cluster create frontend-dev \
  --agents 1 \
  --port "3000:3000@loadbalancer" \
  --port "8080:80@loadbalancer" \
  --volume "$PWD:/workspace@all"

# Hot reload with volume mounts
docker build -t frontend:dev .
k3d image import frontend:dev --cluster frontend-dev
kubectl apply -f k8s/frontend-dev.yaml
```

### Microservices Development  
```bash
# Create service-specific clusters
k3d cluster create auth-service --port "8081:80@loadbalancer"
k3d cluster create user-service --port "8082:80@loadbalancer"  
k3d cluster create order-service --port "8083:80@loadbalancer"

# Or single cluster with port mapping
k3d cluster create microservices \
  --agents 3 \
  --port "8081:8081@loadbalancer" \
  --port "8082:8082@loadbalancer" \
  --port "8083:8083@loadbalancer"
```

### Database Development
```bash
# Cluster with database ports
k3d cluster create db-dev \
  --agents 2 \
  --port "5432:5432@loadbalancer" \
  --port "6379:6379@loadbalancer" \
  --port "27017:27017@loadbalancer" \
  --volume "/data/postgres:/var/lib/postgresql/data@agent:0" \
  --volume "/data/redis:/data@agent:1"
```

### CI/CD Pipeline Testing
```bash
# Lightweight CI cluster
k3d cluster create ci-test \
  --agents 1 \
  --no-lb \
  --wait \
  --timeout 180s

# Run tests
kubectl apply -f test-manifests/
kubectl wait --for=condition=complete job/integration-tests
kubectl logs job/integration-tests
```

### Learning Kubernetes
```bash
# Educational cluster with examples
k3d cluster create learn-k8s \
  --agents 2 \
  --port "8080:80@loadbalancer" \
  --volume "$HOME/k8s-examples:/examples@all"

# Practice scenarios
kubectl apply -f /examples/deployments/
kubectl apply -f /examples/services/
kubectl apply -f /examples/ingress/
```

---

## Cheat Sheet

### Quick Commands
```bash
# CLUSTER OPERATIONS
k3d cluster create <name>                    # Create cluster
k3