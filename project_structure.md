# Restructured Project Structure - Self-Contained Microservices

## Root Directory Structure
```
microservices-k3d/
├── build-all.sh
├── deploy-all.sh
├── cleanup-all.sh
├── setup-k3d.sh
├── test-services.sh
├── k8s-common/
│   ├── namespace.yaml
│   └── configmaps.yaml
├── user-service/
├── product-service/
├── order-service/
├── notification-service/
└── gateway-service/
```

## Detailed Directory Structure

### 1. User Service Structure (Self-Contained)
```
user-service/
├── pom.xml
├── Dockerfile
├── mvnw
├── mvnw.cmd
├── build.sh
├── deploy.sh
├── .mvn/
│   └── wrapper/
│       └── maven-wrapper.properties
├── k8s/
│   └── user-service.yaml
├── src/
│   └── main/
│       ├── java/
│       │   └── com/
│       │       └── example/
│       │           └── userservice/
│       │               ├── UserServiceApplication.java
│       │               ├── controller/
│       │               │   └── UserController.java
│       │               ├── model/
│       │               │   └── User.java
│       │               └── service/
│       │                   └── UserService.java
│       └── resources/
│           └── application.properties
└── README.md
```

### 2. Product Service Structure (Self-Contained)
```
product-service/
├── pom.xml
├── Dockerfile
├── mvnw
├── mvnw.cmd
├── build.sh
├── deploy.sh
├── .mvn/
│   └── wrapper/
│       └── maven-wrapper.properties
├── k8s/
│   └── product-service.yaml
├── src/
│   └── main/
│       ├── java/
│       │   └── com/
│       │       └── example/
│       │           └── productservice/
│       │               ├── ProductServiceApplication.java
│       │               ├── controller/
│       │               │   └── ProductController.java
│       │               ├── model/
│       │               │   └── Product.java
│       │               └── service/
│       │                   └── ProductService.java
│       └── resources/
│           └── application.properties
└── README.md
```

### 3. Order Service Structure (Self-Contained)
```
order-service/
├── pom.xml
├── Dockerfile
├── mvnw
├── mvnw.cmd
├── build.sh
├── deploy.sh
├── .mvn/
│   └── wrapper/
│       └── maven-wrapper.properties
├── k8s/
│   └── order-service.yaml
├── src/
│   └── main/
│       ├── java/
│       │   └── com/
│       │       └── example/
│       │           └── orderservice/
│       │               ├── OrderServiceApplication.java
│       │               ├── controller/
│       │               │   └── OrderController.java
│       │               ├── model/
│       │               │   └── Order.java
│       │               └── service/
│       │                   └── OrderService.java
│       └── resources/
│           └── application.properties
└── README.md
```

### 4. Notification Service Structure (Self-Contained)
```
notification-service/
├── pom.xml
├── Dockerfile
├── mvnw
├── mvnw.cmd
├── build.sh
├── deploy.sh
├── .mvn/
│   └── wrapper/
│       └── maven-wrapper.properties
├── k8s/
│   └── notification-service.yaml
├── src/
│   └── main/
│       ├── java/
│       │   └── com/
│       │       └── example/
│       │           └── notificationservice/
│       │               ├── NotificationServiceApplication.java
│       │               ├── controller/
│       │               │   └── NotificationController.java
│       │               ├── model/
│       │               │   └── Notification.java
│       │               └── service/
│       │                   └── NotificationService.java
│       └── resources/
│           └── application.properties
└── README.md
```

### 5. Gateway Service Structure (Self-Contained)
```
gateway-service/
├── pom.xml
├── Dockerfile
├── mvnw
├── mvnw.cmd
├── build.sh
├── deploy.sh
├── .mvn/
│   └── wrapper/
│       └── maven-wrapper.properties
├── k8s/
│   └── gateway-service.yaml
├── src/
│   └── main/
│       ├── java/
│       │   └── com/
│       │       └── example/
│       │           └── gatewayservice/
│       │               ├── GatewayServiceApplication.java
│       │               └── controller/
│       │                   └── GatewayController.java
│       └── resources/
│           └── application.properties
└── README.md
```

## Commands to Create the Restructured Project

### Step 1: Create Root Directory and Common Files
```bash
# Create root directory
mkdir microservices-k3d
cd microservices-k3d

# Create common scripts
touch build-all.sh deploy-all.sh cleanup-all.sh setup-k3d.sh test-services.sh

# Create common Kubernetes resources
mkdir k8s-common
touch k8s-common/namespace.yaml k8s-common/configmaps.yaml
```

### Step 2: Create Complete Service Structures
```bash
# Create all service directories with their subdirectories
for service in user-service product-service order-service notification-service gateway-service; do
    # Create main directories
    mkdir -p $service/{k8s,.mvn/wrapper}
    mkdir -p $service/src/main/java/com/example/${service/-/}service/{controller,model,service}
    mkdir -p $service/src/main/resources
    
    # Create main files
    touch $service/{pom.xml,Dockerfile,mvnw,mvnw.cmd,build.sh,deploy.sh,README.md}
    touch $service/.mvn/wrapper/maven-wrapper.properties
    touch $service/src/main/resources/application.properties
    touch $service/k8s/${service}.yaml
    
    # Create Java files based on service type
    service_name=$(echo $service | sed 's/-//g')
    package_name=$(echo $service | sed 's/-//')
    
    # Application class
    touch $service/src/main/java/com/example/${package_name}/${service_name^}Application.java
    
    # Controller
    touch $service/src/main/java/com/example/${package_name}/controller/${service_name^}Controller.java
    
    # Model (skip for gateway service)
    if [ "$service" != "gateway-service" ]; then
        touch $service/src/main/java/com/example/${package_name}/model/$(echo $service | sed 's/-service//' | sed 's/.*/\u&/').java
        touch $service/src/main/java/com/example/${package_name}/service/${service_name^}Service.java
    fi
done

# Fix naming for gateway service (no model/service classes needed)
rm gateway-service/src/main/java/com/example/gatewayservice/model/Gateway.java 2>/dev/null
rm gateway-service/src/main/java/com/example/gatewayservice/service/GatewayserviceService.java 2>/dev/null
```

### Step 3: Make Scripts Executable
```bash
# Make all scripts executable
chmod +x *.sh
chmod +x */build.sh */deploy.sh */mvnw
```

## Individual Service Scripts

### Service Build Script Template (build.sh for each service)
```bash
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
```

### Service Deploy Script Template (deploy.sh for each service)
```bash
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
```

## Root Level Scripts

### setup-k3d.sh
```bash
#!/bin/bash

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
```

### build-all.sh
```bash
#!/bin/bash

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
```

### deploy-all.sh
```bash
#!/bin/bash

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
```

### cleanup-all.sh
```bash
#!/bin/bash

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
```

### test-services.sh
```bash
#!/bin/bash

echo "Testing microservices..."

# Port forward to gateway service
kubectl port-forward -n microservices service/gateway-service 8080:8080 &
PF_PID=$!

# Wait for port forward to be ready
sleep 5

echo "Testing API endpoints..."

# Test users
echo "Testing Users API:"
curl -s http://localhost:8080/api/users | jq '.' || echo "Users API test failed"

# Test products  
echo "Testing Products API:"
curl -s http://localhost:8080/api/products | jq '.' || echo "Products API test failed"

# Test creating an order
echo "Testing Order Creation:"
curl -s -X POST http://localhost:8080/api/orders \
  -H "Content-Type: application/json" \
  -d '{"userId":1,"productId":1,"quantity":2}' | jq '.' || echo "Order creation test failed"

# Test notifications
echo "Testing Notifications API:"
curl -s http://localhost:8080/api/notifications | jq '.' || echo "Notifications API test failed"

# Clean up port forward
kill $PF_PID

echo "API testing completed!"
```

## One-Command Project Creation

```bash
# Create the entire restructured project in one command
mkdir microservices-k3d && cd microservices-k3d && \
mkdir -p k8s-common && \
for service in user-service product-service order-service notification-service gateway-service; do \
  mkdir -p $service/{k8s,.mvn/wrapper,src/main/{java/com/example/$(echo $service | sed 's/-//')service/{controller,model,service},resources}} && \
  touch $service/{pom.xml,Dockerfile,mvnw,mvnw.cmd,build.sh,deploy.sh,README.md,.mvn/wrapper/maven-wrapper.properties,src/main/resources/application.properties,k8s/${service}.yaml}; \
done && \
touch {build-all,deploy-all,cleanup-all,setup-k3d,test-services}.sh k8s-common/{namespace,configmaps}.yaml && \
chmod +x *.sh */build.sh */deploy.sh */mvnw
```

## Benefits of This Structure

1. **Self-Contained Services**: Each service has its own build, deploy, and configuration files
2. **Independent Development**: Teams can work on services independently
3. **Easier CI/CD**: Each service can have its own pipeline
4. **Clear Ownership**: Each service directory contains everything needed for that service
5. **Flexible Deployment**: Services can be deployed individually or together
6. **Better Organization**: Configuration files are co-located with their respective services

## Usage Examples

```bash
# Setup entire project
./setup-k3d.sh
./build-all.sh
./deploy-all.sh

# Or work with individual services
cd user-service
./build.sh
./deploy.sh

# Test everything
./test-services.sh

# Cleanup
./cleanup-all.sh
```

This structure follows microservices best practices where each service is truly independent and self-contained!