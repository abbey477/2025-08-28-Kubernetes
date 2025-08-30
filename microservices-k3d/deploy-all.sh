#!/bin/bash
# deploy-all.sh

echo "Deploying all microservices..."

# Deploy in order (dependencies first)
services=("user-service" "product-service" "notification-service" "order-service" "gateway-service")

for service in "${services[@]}"; do
    echo "========================================="
    echo "Deploying $service..."
    echo "========================================="

    cd $service
    ./deploy.sh

    if [ $? -ne 0 ]; then
        echo "Failed to deploy $service"
        exit 1
    fi

    cd ..

    # Wait a bit between deployments
    sleep 10
done

echo "All microservices deployed successfully!"
echo ""
echo "Service URLs (via port-forward):"
echo "Gateway Service: kubectl port-forward -n microservices service/gateway-service 8080:8080"
echo "Individual services can be accessed via: kubectl port-forward -n microservices service/SERVICE-NAME 8081:8080"
