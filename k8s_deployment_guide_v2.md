# Learning to Deploy Spring Boot Microservices to Kubernetes

## Version 1: Remote Kubernetes Cluster with Registry

| Phase | Step | Command/Action | Notes | Learning Tags |
|-------|------|----------------|-------|---------------|
| **Phase 1: Prepare Application** | 1 | `mvn clean package` | Creates executable JAR file in target/ directory | #maven #build |
| | 2 | `java -jar target/your-app.jar` | Test locally before containerizing | #testing #springboot |
| | 3 | Note application port | Usually 8080 for Spring Boot, check application.properties | #configuration |
| **Phase 2: Containerization** | 4 | Create Dockerfile | Define base image, copy JAR, expose port, set entrypoint | #docker #containerization |
| | 5 | `docker build -t your-app:v1 .` | Build image locally, tag with version | #docker #versioning |
| | 6 | `docker run -p 8080:8080 your-app:v1` | Test container works before K8s deployment | #docker #testing |
| | 7 | `docker tag your-app:v1 registry-url/your-app:v1` | Tag for remote registry push | #docker #registry |
| | 8 | `docker push registry-url/your-app:v1` | Upload image to remote registry | #docker #registry |
| **Phase 3: K8s Manifests** | 9 | Write deployment.yaml | Define pods, replicas, container spec, resource limits | #kubernetes #deployment |
| | 10 | Write service.yaml | Create service to expose pods internally/externally | #kubernetes #service #networking |
| | 11 | Write configmap.yaml (optional) | Store configuration data separately from image | #kubernetes #configuration |
| | 12 | Validate YAML syntax | Use IDE or online YAML validator | #yaml #validation |
| **Phase 4: Deploy to K8s** | 13 | Configure kubectl | Set kubeconfig to point to remote cluster | #kubectl #configuration |
| | 14 | `kubectl get nodes` | Verify cluster connection and health | #kubectl #troubleshooting |
| | 15 | `kubectl create namespace your-app` | Isolate your application resources | #kubernetes #namespaces |
| | 16 | `kubectl apply -f deployment.yaml` | Create deployment resource | #kubectl #deployment |
| | 17 | `kubectl apply -f service.yaml` | Create service resource | #kubectl #service |
| | 18 | `kubectl apply -f configmap.yaml` | Apply other resources as needed | #kubectl #configuration |
| **Phase 5: Verify Deployment** | 19 | `kubectl get pods` | Check if pods are running successfully | #kubectl #monitoring |
| | 20 | `kubectl logs pod-name` | View application logs for debugging | #kubectl #troubleshooting |
| | 21 | `kubectl get services` | Verify service is created and has endpoints | #kubectl #networking |
| | 22 | `kubectl describe deployment your-app` | Get detailed deployment information | #kubectl #troubleshooting |
| **Phase 6: Access Application** | 23 | `kubectl port-forward service/your-service 8080:8080` | Create local tunnel to service for testing | #kubectl #networking |
| | 24 | Open `http://localhost:8080/your-endpoint` | Test application in browser | #testing #verification |
| | 25 | Create LoadBalancer/Ingress (optional) | For external access without port-forward | #kubernetes #ingress #loadbalancer |
| | 26 | Access via external IP | Use cluster's external IP and service port | #networking #external-access |
| **Phase 7: Iterate & Learn** | 27 | Modify Spring Boot code | Make changes to understand deployment cycle | #development #iteration |
| | 28 | Repeat phases 1-6 | Full redeploy cycle for changes | #cicd #deployment-cycle |
| | 29 | `kubectl scale deployment your-app --replicas=3` | Learn horizontal scaling | #kubernetes #scaling |
| | 30 | Monitor with kubectl commands | Use logs, describe, get events for troubleshooting | #monitoring #troubleshooting |

---

## Version 2: Local Development (No Registry Required)

| Phase | Step | Command/Action | Notes | Learning Tags |
|-------|------|----------------|-------|---------------|
| **Phase 1: Prepare Application** | 1 | `mvn clean package` | Creates executable JAR file in target/ directory | #maven #build |
| | 2 | `java -jar target/your-app.jar` | Test locally before containerizing | #testing #springboot |
| | 3 | Note application port | Usually 8080 for Spring Boot, check application.properties | #configuration |
| **Phase 2: Local Containerization** | 4 | Create Dockerfile | Define base image, copy JAR, expose port, set entrypoint | #docker #containerization |
| | 5 | `docker build -t your-app:v1 .` | Build image locally with local tag | #docker #local-development |
| | 6 | `docker run -p 8080:8080 your-app:v1` | Test container works before K8s deployment | #docker #testing |
| | 7 | Load image to local K8s | `kind load docker-image your-app:v1` (for kind) or `minikube image load your-app:v1` (for minikube) | #local-kubernetes #image-loading |
| **Phase 3: K8s Manifests** | 8 | Write deployment.yaml | Use `imagePullPolicy: Never` or `imagePullPolicy: IfNotPresent` for local images | #kubernetes #deployment #local-images |
| | 9 | Write service.yaml | Create service to expose pods (NodePort recommended for local) | #kubernetes #service #local-networking |
| | 10 | Write configmap.yaml (optional) | Store configuration data separately from image | #kubernetes #configuration |
| | 11 | Validate YAML syntax | Use IDE or online YAML validator | #yaml #validation |
| **Phase 4: Deploy to Local K8s** | 12 | Verify local cluster | `kubectl get nodes` - should show local cluster nodes | #kubectl #local-cluster |
| | 13 | `kubectl create namespace your-app` | Isolate your application resources (optional for local) | #kubernetes #namespaces |
| | 14 | `kubectl apply -f deployment.yaml` | Create deployment resource | #kubectl #deployment |
| | 15 | `kubectl apply -f service.yaml` | Create service resource | #kubectl #service |
| | 16 | `kubectl apply -f configmap.yaml` | Apply other resources as needed | #kubectl #configuration |
| **Phase 5: Verify Deployment** | 17 | `kubectl get pods` | Check if pods are running successfully | #kubectl #monitoring |
| | 18 | `kubectl logs pod-name` | View application logs for debugging | #kubectl #troubleshooting |
| | 19 | `kubectl get services` | Verify service is created and has endpoints | #kubectl #networking |
| | 20 | `kubectl describe deployment your-app` | Get detailed deployment information | #kubectl #troubleshooting |
| **Phase 6: Access Application** | 21 | Get service URL | `minikube service your-service --url` (minikube) or `kubectl get service` + NodePort | #local-networking #service-discovery |
| | 22 | Open browser to service URL | Direct access to your application | #testing #verification |
| | 23 | Alternative: Port forward | `kubectl port-forward service/your-service 8080:8080` | #kubectl #port-forwarding |
| **Phase 7: Iterate & Learn** | 24 | Modify Spring Boot code | Make changes to understand local development cycle | #development #iteration |
| | 25 | Rebuild and reload image | `docker build` + `kind/minikube load` + `kubectl rollout restart` | #local-development #hot-reload |
| | 26 | `kubectl scale deployment your-app --replicas=3` | Learn horizontal scaling in local environment | #kubernetes #scaling |
| | 27 | Experiment with K8s features | Try different service types, add health checks, resource limits | #kubernetes #experimentation |

## Key Differences for Local Development

### Image Management
- **Remote**: Push to registry, K8s pulls from registry
- **Local**: Load image directly into local cluster, no registry needed

### Service Access
- **Remote**: External LoadBalancer or Ingress for public access
- **Local**: NodePort services or port-forwarding for localhost access

### Development Speed
- **Remote**: Slower iteration due to registry push/pull
- **Local**: Faster iteration, immediate image availability

### Learning Focus
- **Remote**: Production-like workflow, registry management
- **Local**: K8s fundamentals without infrastructure complexity

---

## Version 3: Local Development with Helm Charts

| Phase | Step | Command/Action | Notes | Learning Tags |
|-------|------|----------------|-------|---------------|
| **Phase 1: Prepare Application** | 1 | `mvn clean package` | Creates executable JAR file in target/ directory | #maven #build |
| | 2 | `java -jar target/your-app.jar` | Test locally before containerizing | #testing #springboot |
| | 3 | Note application port | Usually 8080 for Spring Boot, check application.properties | #configuration |
| **Phase 2: Local Containerization** | 4 | Create Dockerfile | Define base image, copy JAR, expose port, set entrypoint | #docker #containerization |
| | 5 | `docker build -t your-app:v1 .` | Build image locally with local tag | #docker #local-development |
| | 6 | `docker run -p 8080:8080 your-app:v1` | Test container works before K8s deployment | #docker #testing |
| | 7 | Load image to local K8s | `kind load docker-image your-app:v1` (for kind) or `minikube image load your-app:v1` (for minikube) | #local-kubernetes #image-loading |
| **Phase 3: Install Helm** | 8 | Install Helm | Download and install Helm CLI on your machine | #helm #installation |
| | 9 | `helm version` | Verify Helm installation and check version | #helm #verification |
| | 10 | `helm repo add stable https://charts.helm.sh/stable` | Add common Helm repository (optional for learning) | #helm #repositories |
| **Phase 4: Create Helm Chart** | 11 | `helm create my-spring-app` | Generate boilerplate Helm chart structure | #helm #chart-creation |
| | 12 | Explore chart structure | Review templates/, values.yaml, Chart.yaml files | #helm #chart-structure |
| | 13 | Edit values.yaml | Set image repository, tag, service type, port | #helm #values #configuration |
| | 14 | Customize deployment template | Modify templates/deployment.yaml for Spring Boot specifics | #helm #templates #customization |
| | 15 | Customize service template | Modify templates/service.yaml for your service needs | #helm #templates #service |
| | 16 | Add ConfigMap template (optional) | Create templates/configmap.yaml for app configuration | #helm #templates #configmap |
| **Phase 5: Validate Helm Chart** | 17 | `helm lint my-spring-app/` | Check chart for potential issues and best practices | #helm #validation #linting |
| | 18 | `helm template my-spring-app my-spring-app/` | Generate K8s manifests without deploying | #helm #dry-run #templates |
| | 19 | Review generated YAML | Compare with your original manual YAML files | #helm #comparison #learning |
| | 20 | `helm install --dry-run --debug my-spring-app my-spring-app/` | Simulate installation to catch errors | #helm #dry-run #debugging |
| **Phase 6: Deploy with Helm** | 21 | `helm install my-spring-app my-spring-app/` | Deploy your application using Helm | #helm #deployment #installation |
| | 22 | `helm list` | View all Helm releases in current namespace | #helm #release-management |
| | 23 | `helm status my-spring-app` | Check status of your Helm release | #helm #status #monitoring |
| | 24 | `kubectl get all -l app.kubernetes.io/instance=my-spring-app` | View all resources created by Helm | #kubectl #helm #labels |
| **Phase 7: Verify Deployment** | 25 | `kubectl get pods` | Check if pods are running successfully | #kubectl #monitoring |
| | 26 | `kubectl logs -l app.kubernetes.io/name=my-spring-app` | View logs using Helm labels | #kubectl #logs #helm-labels |
| | 27 | `kubectl get services` | Verify service is created and has endpoints | #kubectl #networking |
| | 28 | `helm get values my-spring-app` | See what values were used in deployment | #helm #values #troubleshooting |
| **Phase 8: Access Application** | 29 | Get service URL | `minikube service my-spring-app --url` or check NodePort | #local-networking #service-discovery |
| | 30 | Open browser to service URL | Test your Helm-deployed application | #testing #verification |
| | 31 | Alternative: Port forward | `kubectl port-forward service/my-spring-app 8080:8080` | #kubectl #port-forwarding |
| **Phase 9: Helm Operations** | 32 | Update values.yaml | Change replicas, image tag, or other configurations | #helm #values #configuration |
| | 33 | `helm upgrade my-spring-app my-spring-app/` | Update deployment with new values | #helm #upgrade #release-management |
| | 34 | `helm history my-spring-app` | View release history and revisions | #helm #history #versioning |
| | 35 | `helm rollback my-spring-app 1` | Rollback to previous version if needed | #helm #rollback #disaster-recovery |
| **Phase 10: Advanced Helm Learning** | 36 | Create multiple environments | Use different values files (values-dev.yaml, values-prod.yaml) | #helm #environments #multi-env |
| | 37 | `helm install -f values-dev.yaml dev-app my-spring-app/` | Deploy to different environment with specific values | #helm #environments #values-files |
| | 38 | Add dependencies | Include database or other services in Chart.yaml dependencies | #helm #dependencies #complex-apps |
| | 39 | Use Helm hooks | Add pre/post install hooks for database migrations | #helm #hooks #lifecycle |
| | 40 | Package and share | `helm package my-spring-app/` to create distributable chart | #helm #packaging #distribution |

## Helm Advantages You'll Learn

### Template Reusability
- **Without Helm**: Copy-paste YAML files for each microservice
- **With Helm**: One chart template, different values for each service

### Environment Management  
- **Without Helm**: Separate YAML files for dev/staging/prod
- **With Helm**: Same chart, different values files per environment

### Release Management
- **Without Helm**: Manual tracking of what's deployed
- **With Helm**: Built-in release history, upgrades, rollbacks

### Configuration Management
- **Without Helm**: Hard-coded values in YAML files
- **With Helm**: Centralized values.yaml with environment overrides

### Dependency Management
- **Without Helm**: Manual deployment order for related services
- **With Helm**: Automatic dependency resolution and installation

## Key Helm Concepts to Understand

### Chart Structure
```
my-spring-app/
├── Chart.yaml          # Chart metadata
├── values.yaml         # Default values
├── templates/          # K8s manifest templates
│   ├── deployment.yaml
│   ├── service.yaml
│   └── configmap.yaml
└── charts/            # Chart dependencies
```

### Values Hierarchy
1. **Default**: values.yaml in chart
2. **Override**: -f custom-values.yaml 
3. **Command line**: --set key=value
4. **Environment**: values-dev.yaml, values-prod.yaml

### Template Functions
- `{{ .Values.image.repository }}` - Access values
- `{{ include "chart.fullname" . }}` - Use helper templates  
- `{{ if .Values.ingress.enabled }}` - Conditional logic
- `{{ range .Values.env }}` - Loops and iteration

This version teaches you how Helm solves real problems you'll encounter as you scale from one microservice to many, while maintaining the hands-on learning approach.