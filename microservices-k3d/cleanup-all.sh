#!/bin/bash
# cleanup-all.sh

echo "Cleaning up all microservices..."

# Delete all services
services=("gateway-service" "order-service" "notification-service" "product-service" "user-service")

for service in "${services[@]}"; do
    echo "Deleting $service..."
    kubectl delete -f $service/k8s/${service}.yaml --ignore-not-found=true
done

# Delete common resources
kubectl delete -f k8s-common/ --ignore-not-found=true

# Or delete entire namespace (uncomment if preferred)
# kubectl delete namespace microservices

echo "Cleanup completed!"