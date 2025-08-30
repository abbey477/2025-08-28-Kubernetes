#!/bin/bash
# build-all.sh

echo "Building all microservices..."

services=("user-service" "product-service" "order-service" "notification-service" "gateway-service")

for service in "${services[@]}"; do
    echo "========================================="
    echo "Building $service..."
    echo "========================================="

    cd $service
    ./build.sh

    if [ $? -ne 0 ]; then
        echo "Failed to build $service"
        exit 1
    fi

    cd ..
done

echo "All microservices built successfully!"