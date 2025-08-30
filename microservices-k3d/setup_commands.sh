# Complete Project Setup Commands

# Step 1: Create the project structure
mkdir microservices-k3d && cd microservices-k3d

# Create common directories
mkdir -p k8s-common

# Create all service directories with their subdirectories
for service in user-service product-service order-service notification-service gateway-service; do
    # Create main directories
    mkdir -p $service/{k8s,.mvn/wrapper}
    mkdir -p $service/src/main/java/com/example/$(echo $service | sed 's/-//g')/{controller,model,service}
    mkdir -p $service/src/main/resources
    
    # Create main files
    touch $service/{pom.xml,Dockerfile,mvnw,mvnw.cmd,build.sh,deploy.sh,README.md}
    touch $service/.mvn/wrapper/maven-wrapper.properties
    touch $service/src/main/resources/application.properties
    touch $service/k8s/${service}.yaml
done

# Remove unnecessary files for gateway service
rm gateway-service/src/main/java/com/example/gatewayservice/model 2>/dev/null
rm gateway-service/src/main/java/com/example/gatewayservice/service 2>/dev/null

# Create root level scripts and configs
touch {build-all,deploy-all,cleanup-all,setup-k3d,test-services}.sh
touch k8s-common/{namespace,configmaps}.yaml

# Step 2: Make scripts executable
chmod +x *.sh
chmod +x */build.sh */deploy.sh */mvnw

echo "Project structure created successfully!"

---
# Step 3: Download Maven Wrapper for each service
# Run this for each service directory
download_maven_wrapper() {
    local service_dir=$1
    cd $service_dir
    
    # Download maven wrapper jar
    mkdir -p .mvn/wrapper
    curl -o .mvn/wrapper/maven-wrapper.jar https://repo.maven.apache.org/maven2/org/apache/maven/wrapper/maven-wrapper/3.2.0/maven-wrapper-3.2.0.jar
    
    # Download maven wrapper script
    curl -o mvnw https://raw.githubusercontent.com/apache/maven/master/maven-wrapper/src/main/resources/mvnw
    curl -o mvnw.cmd https://raw.githubusercontent.com/apache/maven/master/maven-wrapper/src/main/resources/mvnw.cmd
    
    chmod +x mvnw
    cd ..
}

# Download for all services
for service in user-service product-service order-service notification-service gateway-service; do
    download_maven_wrapper $service
done

---
# Alternative: Quick Maven Wrapper Setup
# If the download approach doesn't work, create minimal mvnw files

create_minimal_mvnw() {
    local service_dir=$1
    cd $service_dir
    
    cat > mvnw << 'EOF'
#!/bin/sh
exec java -jar .mvn/wrapper/maven-wrapper.jar "$@"
EOF
    
    chmod +x mvnw
    cd ..
}

# Use this if needed
for service in user-service product-service order-service notification-service gateway-service; do
    create_minimal_mvnw $service
done

---
# Step 4: File Contents Setup Script
setup_file_contents() {
    echo "Setting up file contents..."
    
    # You need to copy the contents from the artifacts above into respective files
    # This is a reference for what needs to be copied where:
    
    echo "Copy the following contents to respective files:"
    echo "1. Common configs → k8s-common/ files"
    echo "2. Root scripts → root directory .sh files"
    echo "3. User service code → user-service/ files"
    echo "4. Product service code → product-service/ files"
    echo "5. Order service code → order-service/ files"
    echo "6. Notification service code → notification-service/ files"
    echo "7. Gateway service code → gateway-service/ files"
    
    # Maven wrapper properties for all services
    for service in user-service product-service order-service notification-service gateway-service; do
        cat > $service/.mvn/wrapper/maven-wrapper.properties << 'EOF'
distributionUrl=https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.9.5/apache-maven-3.9.5-bin.zip
wrapperUrl=https://repo.maven.apache.org/maven2/org/apache/maven/wrapper/maven-wrapper/3.2.0/maven-wrapper-3.2.0.jar
EOF
    done
}

setup_file_contents

---
# Step 5: Quick Deployment Commands

# Setup k3d and deploy everything
deploy_everything() {
    echo "Setting up and deploying microservices..."
    
    # Setup k3d cluster
    ./setup-k3d.sh
    
    # Build all services
    ./build-all.sh
    
    # Deploy all services
    ./deploy-all.sh
    
    # Test services
    ./test-services.sh
}

# Individual service deployment
deploy_single_service() {
    local service_name=$1
    cd $service_name
    ./build.sh
    ./deploy.sh
    cd ..
}

---
# Step 6: Verification Commands

verify_deployment() {
    echo "Verifying deployment..."
    
    # Check cluster status
    kubectl cluster-info
    
    # Check all pods
    kubectl get pods -n microservices
    
    # Check all services
    kubectl get svc -n microservices
    
    # Check deployments
    kubectl get deployments -n microservices
    
    # Test connectivity
    echo "Testing service connectivity..."
    kubectl port-forward -n microservices service/gateway-service 8080:8080 &
    PF_PID=$!
    
    sleep 5
    
    # Test APIs
    curl -s http://localhost:8080/api/users || echo "Users API not accessible"
    curl -s http://localhost:8080/api/products || echo "Products API not accessible"
    
    # Cleanup port forward
    kill $PF_PID
}

---
# Step 7: Troubleshooting Commands

troubleshoot() {
    echo "Troubleshooting commands:"
    
    # Check pod logs
    echo "Check logs for any service:"
    echo "kubectl logs -f deployment/SERVICE-NAME -n microservices"
    
    # Check pod status
    echo "Check pod details:"
    echo "kubectl describe pod POD-NAME -n microservices"
    
    # Check events
    echo "Check cluster events:"
    echo "kubectl get events -n microservices --sort-by=.metadata.creationTimestamp"
    
    # Check images
    echo "List imported images:"
    echo "k3d image list --cluster microservices-cluster"
    
    # Restart deployment
    echo "Restart a deployment:"
    echo "kubectl rollout restart deployment/SERVICE-NAME -n microservices"
}

---
# Complete Project README.md
cat > README.md << 'EOF'
# Microservices on k3d Kubernetes

This project demonstrates 5 Spring Boot microservices deployed on k3d Kubernetes:

## Services
- **User Service**: Manages users
- **Product Service**: Manages products  
- **Order Service**: Creates orders (calls User & Product services)
- **Notification Service**: Sends notifications
- **Gateway Service**: API Gateway (routes requests)

## Quick Start

### Prerequisites
- Docker
- kubectl
- k3d
- Java 17+
- Maven (or use included wrapper)

### Setup and Deploy
```bash
# 1. Setup k3d cluster
./setup-k3d.sh

# 2. Build all services
./build-all.sh

# 3. Deploy all services
./deploy-all.sh

# 4. Test services
./test-services.sh
```

### Individual Service Management
```bash
# Build individual service
cd user-service
./build.sh

# Deploy individual service  
./deploy.sh
```

### Testing
```bash
# Port forward to gateway
kubectl port-forward -n microservices service/gateway-service 8080:8080

# Test APIs
curl http://localhost:8080/api/users
curl http://localhost:8080/api/products
curl -X POST http://localhost:8080/api/orders \
  -H "Content-Type: application/json" \
  -d '{"userId":1,"productId":1,"quantity":2}'
```

### Cleanup
```bash
./cleanup-all.sh
k3d cluster delete microservices-cluster
```

## Architecture
- Gateway Service routes external requests
- Order Service orchestrates user validation, product updates, and notifications
- All services communicate via Kubernetes DNS
- No external registry required (images loaded directly into k3d)
EOF

echo "Setup complete! Your microservices project is ready."
echo ""
echo "Next steps:"
echo "1. Copy the source code from the artifacts above into respective files"
echo "2. Run: ./setup-k3d.sh"
echo "3. Run: ./build-all.sh"
echo "4. Run: ./deploy-all.sh"
echo "5. Run: ./test-services.sh"