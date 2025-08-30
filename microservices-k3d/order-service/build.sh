#!/bin/bash

SERVICE_NAME=$(basename $(pwd))
echo "Building $SERVICE_NAME..."

# Build JAR file
./mvnw clean package -DskipTests

if [ $? -eq 0 ]; then
    echo "JAR build successful for $SERVICE_NAME"

    # Build Docker image
    docker build -t $SERVICE_NAME:latest .

    if [ $? -eq 0 ]; then
        echo "Docker build successful for $SERVICE_NAME"

        # Load image into k3d cluster
        k3d image import $SERVICE_NAME:latest --cluster microservices-cluster
        echo "$SERVICE_NAME image loaded into k3d cluster"
    else
        echo "Docker build failed for $SERVICE_NAME"
        exit 1
    fi
else
    echo "JAR build failed for $SERVICE_NAME"
    exit 1
fi