#!/bin/bash
# setup-k3d.sh

echo "Setting up k3d cluster for microservices..."

# Create k3d cluster
k3d cluster create microservices-cluster --port "8080:80@loadbalancer"

if [ $? -eq 0 ]; then
    echo "k3d cluster created successfully"

    # Verify cluster
    kubectl cluster-info
    kubectl get nodes

    # Apply common resources
    echo "Applying common Kubernetes resources..."
    kubectl apply -f k8s-common/

    echo "k3d setup completed!"
else
    echo "Failed to create k3d cluster"
    exit 1
fi