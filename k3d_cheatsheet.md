# K3d Command Cheatsheet

## 🚀 Cluster Management

### Create Clusters
```bash
# Basic cluster
k3d cluster create mycluster

# Cluster with custom name and agents
k3d cluster create dev --agents 3

# Cluster with port mapping
k3d cluster create web-cluster \
  --port "8080:80@loadbalancer" \
  --port "8443:443@loadbalancer"

# Cluster with specific k3s version
k3d cluster create legacy --image rancher/k3s:v1.24.8-k3s1

# Cluster with volume mounts
k3d cluster create data-cluster \
  --volume "/host/path:/container/path@all"

# Cluster without load balancer
k3d cluster create simple --no-lb

# Cluster with custom registry
k3d cluster create registry-cluster \
  --registry-create myregistry:5000
```

### List & Inspect Clusters
```bash
# List all clusters
k3d cluster list

# Get cluster info
k3d cluster get mycluster

# Show kubeconfig for cluster
k3d kubeconfig get mycluster
```

### Start/Stop/Delete Clusters
```bash
# Start cluster
k3d cluster start mycluster

# Stop cluster
k3d cluster stop mycluster

# Delete cluster
k3d cluster delete mycluster

# Delete all clusters
k3d cluster delete --all
```

## 📦 Node Management

### Add Nodes
```bash
# Add agent node to existing cluster
k3d node create new-agent --cluster mycluster --role agent

# Add multiple agent nodes
k3d node create agent-1 agent-2 --cluster mycluster --role agent

# Add server node (control plane)
k3d node create new-server --cluster mycluster --role server
```

### List & Inspect Nodes
```bash
# List all nodes
k3d node list

# List nodes in specific cluster
k3d node list mycluster

# Get node details
k3d node get node-name
```

### Start/Stop/Delete Nodes
```bash
# Start node
k3d node start node-name

# Stop node
k3d node stop node-name

# Delete node
k3d node delete node-name

# Delete multiple nodes
k3d node delete node-1 node-2
```

## 🖥️ Kubeconfig Management

```bash
# Get kubeconfig for cluster
k3d kubeconfig get mycluster

# Merge cluster kubeconfig with default
k3d kubeconfig merge mycluster --kubeconfig-merge-default

# Write kubeconfig to file
k3d kubeconfig get mycluster > ~/k3d-mycluster.kubeconfig

# Use specific kubeconfig
export KUBECONFIG=~/k3d-mycluster.kubeconfig

# Switch between cluster contexts
kubectl config use-context k3d-mycluster
kubectl config get-contexts
```

## 🐳 Registry Commands

```bash
# Create registry
k3d registry create myregistry --port 5000

# List registries
k3d registry list

# Delete registry
k3d registry delete myregistry

# Create cluster with registry
k3d cluster create mycluster --registry-use k3d-myregistry:5000
```

## 🔧 Image Management

```bash
# Import image into cluster
k3d image import myapp:latest --cluster mycluster

# Import multiple images
k3d image import nginx:latest redis:alpine --cluster mycluster

# Import from tar file
k3d image import myimage.tar --cluster mycluster
```

## 🌐 Common Cluster Configurations

### Development Cluster
```bash
k3d cluster create dev \
  --agents 2 \
  --port "8080:80@loadbalancer" \
  --port "8443:443@loadbalancer" \
  --port "30000-32767:30000-32767@server:0" \
  --volume "/tmp/k3d-dev:/tmp@all"
```

### Multi-Master (HA) Cluster
```bash
k3d cluster create ha-cluster \
  --servers 3 \
  --agents 3 \
  --port "6443:6443@loadbalancer"
```

### Cluster with GPU Support
```bash
k3d cluster create gpu-cluster \
  --gpus all \
  --image rancher/k3s:latest
```

### Cluster with Custom Network
```bash
k3d cluster create network-cluster \
  --network my-custom-network \
  --subnet 172.28.0.0/16
```

## 🔍 Troubleshooting Commands

```bash
# Check cluster status
kubectl cluster-info --context k3d-mycluster

# Check node status
kubectl get nodes

# Check all pods
kubectl get pods --all-namespaces

# Check cluster events
kubectl get events --sort-by='.lastTimestamp'

# Access cluster logs
k3d cluster list
docker logs k3d-mycluster-server-0

# Shell into node
docker exec -it k3d-mycluster-server-0 /bin/sh
```

## 📋 Useful Kubectl Context Switching

```bash
# Quick context switch
kubectl config use-context k3d-dev
kubectl config use-context k3d-staging
kubectl config use-context k3d-prod

# Create alias for quick switching
alias k3dev='kubectl config use-context k3d-dev'
alias k3stage='kubectl config use-context k3d-staging'
alias k3prod='kubectl config use-context k3d-prod'
```

## 🚨 Quick Cleanup

```bash
# Stop all clusters
k3d cluster stop --all

# Delete all clusters
k3d cluster delete --all

# Remove all k3d containers and networks
docker system prune -f
docker network prune -f
```

## 💡 Pro Tips

1. **Use meaningful cluster names**: `dev`, `staging`, `feature-auth`, etc.
2. **Always specify ports** for web applications: `--port "8080:80@loadbalancer"`
3. **Use volumes** for persistent development: `--volume "/host/src:/app@all"`
4. **Create aliases** for frequently used clusters
5. **Tag your images** before importing: `docker tag myapp:latest myapp:dev`
6. **Use registries** for sharing images between clusters
7. **Check cluster logs** when things go wrong: `docker logs k3d-<cluster>-server-0`

## 🔗 Quick Setup Script

```bash
#!/bin/bash
# Create development environment
k3d cluster create dev \
  --agents 2 \
  --port "8080:80@loadbalancer" \
  --port "8443:443@loadbalancer" \
  --volume "$PWD:/workspace@all"

# Set kubectl context
kubectl config use-context k3d-dev

# Verify setup
kubectl get nodes
echo "✅ Dev cluster ready at localhost:8080"
```