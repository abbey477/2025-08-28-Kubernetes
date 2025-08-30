# Microservice to k3d Deployment Steps

| Step | Category | Action | Command/File | Comments |
|------|----------|--------|--------------|----------|
| 1 | **Prerequisites** | Install Docker | `docker --version` | Container runtime for building and running images |
| 2 | **Prerequisites** | Install k3d | `curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh \| bash` | Lightweight Kubernetes distribution in Docker |
| 3 | **Prerequisites** | Install kubectl | Platform-specific installation | Kubernetes command-line tool |
| 4 | **Prerequisites** | Verify installations | `k3d version && kubectl version --client` | Ensure all tools are working |
| 5 | **App Development** | Create project structure | Create directories | Organize Spring Boot app and k8s manifests |
| 6 | **App Development** | Write Spring Boot code | `pom.xml`, Java classes | Main app, controllers, models with JSON support |
| 7 | **App Development** | Create Dockerfile | `Dockerfile` | Containerize the Spring Boot application |
| 8 | **App Development** | Test locally (optional) | `mvn spring-boot:run` | Verify app works before containerizing |
| 9 | **Cluster Setup** | Create k3d cluster | `k3d cluster create my-cluster --port "8080:80@loadbalancer"` | Creates local Kubernetes cluster with port mapping |
| 10 | **Cluster Setup** | Verify cluster | `kubectl cluster-info && kubectl get nodes` | Ensure cluster is running and accessible |
| 11 | **Image Management** | Build Docker image | `docker build -t my-microservice:v1 .` | Create container image from Dockerfile |
| 12 | **Image Management** | Import image to k3d | `k3d image import my-microservice:v1 -c my-cluster` | **Critical**: Makes local image available inside cluster |
| 13 | **Configuration** | Create namespace | `k8s/namespace.yaml` | Isolate resources in dedicated namespace |
| 14 | **Configuration** | Create ConfigMap | `k8s/configmap.yaml` | Store nginx config and app properties |
| 15 | **App Deployment** | Create microservice deployment | `k8s/microservice-deployment.yaml` | Define pods, replicas, health checks, resources |
| 16 | **App Deployment** | Create microservice service | `k8s/microservice-service.yaml` | Internal networking for microservice pods |
| 17 | **Load Balancer** | Create nginx deployment | `k8s/nginx-deployment.yaml` | Load balancer pods with nginx configuration |
| 18 | **Load Balancer** | Create nginx service | `k8s/nginx-service.yaml` | External access point (LoadBalancer type) |
| 19 | **Networking** | Create ingress (optional) | `k8s/ingress.yaml` | HTTP routing rules for external access |
| 20 | **Deployment** | Apply namespace | `kubectl apply -f k8s/namespace.yaml` | Create the namespace first |
| 21 | **Deployment** | Apply ConfigMap | `kubectl apply -f k8s/configmap.yaml` | Load configuration data |
| 22 | **Deployment** | Apply microservice manifests | `kubectl apply -f k8s/microservice-*` | Deploy the Spring Boot application |
| 23 | **Deployment** | Apply nginx manifests | `kubectl apply -f k8s/nginx-*` | Deploy the load balancer |
| 24 | **Deployment** | Apply ingress (optional) | `kubectl apply -f k8s/ingress.yaml` | Setup HTTP routing |
| 25 | **Verification** | Check pod status | `kubectl get pods -n my-app` | Verify all pods are running |
| 26 | **Verification** | Check services | `kubectl get svc -n my-app` | Verify services are created and have endpoints |
| 27 | **Verification** | Check logs | `kubectl logs -l app=my-microservice -n my-app` | Troubleshoot any startup issues |
| 28 | **Testing** | Port forward service | `kubectl port-forward svc/nginx-lb 8080:80 -n my-app` | Access the service locally for testing |
| 29 | **Testing** | Test REST endpoints | `curl http://localhost:8080/api/users` | Verify JSON API is working |
| 30 | **Testing** | Test load balancing | Multiple curl requests | Verify traffic distribution across pods |
| 31 | **Testing** | Test CRUD operations | POST/PUT/DELETE with JSON | Verify full REST API functionality |
| 32 | **Monitoring** | Monitor pod health | `kubectl get pods -n my-app -w` | Watch pod status in real-time |
| 33 | **Scaling** | Scale microservice | `kubectl scale deployment my-microservice --replicas=5 -n my-app` | Test horizontal scaling |
| 34 | **Updates** | Build new version | `docker build -t my-microservice:v2 .` | Create updated image |
| 35 | **Updates** | Import new image | `k3d image import my-microservice:v2 -c my-cluster` | Make new version available |
| 36 | **Updates** | Rolling update | `kubectl set image deployment/my-microservice my-microservice=my-microservice:v2 -n my-app` | Deploy new version with zero downtime |
| 37 | **Cleanup** | Delete resources | `kubectl delete namespace my-app` | Remove all application resources |
| 38 | **Cleanup** | Delete cluster | `k3d cluster delete my-cluster` | Clean up the entire cluster |

## **Critical Steps Explained:**

- **Step 12** (Image Import): Most important step for k3d - without this, pods will fail with `ImagePullBackOff`
- **Steps 20-24** (Apply Order): Order matters - namespace first, then ConfigMap, then deployments
- **Step 28** (Port Forward): Necessary for local testing since k3d doesn't expose LoadBalancer IPs by default
- **Steps 34-36** (Updates): Proper workflow for deploying new versions

## **Common Failure Points:**
- **Skipping image import** (Step 12) - leads to image pull failures
- **Wrong apply order** - ConfigMaps must exist before deployments reference them
- **Missing port-forward** - can't access services without proper networking setup
- **Incorrect service names** - nginx config must match Kubernetes service names exactly