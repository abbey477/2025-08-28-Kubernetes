# 1. Create root directory
mkdir microservices-k3d
cd microservices-k3d

# 2. Create all directories and files in one command
mkdir -p {user-service,product-service,order-service,notification-service,gateway-service}/src/main/java/com/example/{userservice,productservice,orderservice,notificationservice,gatewayservice}/{controller,model,service} && \
mkdir -p {user-service,product-service,order-service,notification-service,gateway-service}/src/main/resources && \
mkdir -p {user-service,product-service,order-service,notification-service,gateway-service}/.mvn/wrapper && \
touch build-images.sh deploy.sh cleanup.sh namespace.yaml configmaps.yaml {user,product,order,notification,gateway}-service.yaml

# 3. Create individual service files
for service in user-service product-service order-service notification-service gateway-service; do
  touch $service/{pom.xml,Dockerfile,mvnw,mvnw.cmd}
  touch $service/.mvn/wrapper/maven-wrapper.properties
  touch $service/src/main/resources/application.properties
done

# 4. Make scripts executable
chmod +x build-images.sh deploy.sh cleanup.sh
chmod +x */mvnw

# 5. Verify structure
tree . -I target
