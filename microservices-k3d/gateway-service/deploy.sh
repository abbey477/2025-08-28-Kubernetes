#!/bin/bash

SERVICE_NAME=$(basename $(pwd))
echo "Deploying $SERVICE_NAME to Kubernetes..."

# Apply the Kubernetes manifest
kubectl apply -f k8s/${SERVICE_NAME}.yaml

if [ $? -eq 0 ]; then
    echo "$SERVICE_NAME deployed successfully"

    # Wait for deployment to be ready
    echo "Waiting for $SERVICE_NAME to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/$SERVICE_NAME -n microservices

    if [ $? -eq 0 ]; then
        echo "$SERVICE_NAME is ready!"
        kubectl get pods -l app=$SERVICE_NAME -n microservices
    else
        echo "Timeout waiting for $SERVICE_NAME to be ready"
        exit 1
    fi
else
    echo "Failed to deploy $SERVICE_NAME"
    exit 1
fi