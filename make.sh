# Create entire project structure in one command
mkdir microservices-k3d && cd microservices-k3d && \
mkdir -p k8s-common && \
for service in user-service product-service order-service notification-service gateway-service; do \
  mkdir -p $service/{k8s,.mvn/wrapper,src/main/{java/com/example/$(echo $service | sed 's/-//')service/{controller,model,service},resources}} && \
  touch $service/{pom.xml,Dockerfile,mvnw,mvnw.cmd,build.sh,deploy.sh,README.md,.mvn/wrapper/maven-wrapper.properties,src/main/resources/application.properties,k8s/${service}.yaml}; \
done && \
touch {build-all,deploy-all,cleanup-all,setup-k3d,test-services}.sh k8s-common/{namespace,configmaps}.yaml && \
chmod +x *.sh */build.sh */deploy.sh */mvnw
