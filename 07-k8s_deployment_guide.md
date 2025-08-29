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