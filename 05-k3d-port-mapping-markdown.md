# k3d Port Mapping Flow - Complete Guide

## Understanding the Port Connection Chain

The relationship between `--port "8080:80@loadbalancer"` and your service.yaml is like a **chain of port forwards** that must all connect properly.

## Visual Flow Diagram

```
Browser Request          Docker Host           k3d LoadBalancer       Kubernetes Service      Spring Boot Pod
localhost:8080    →     Host:8080      →      Container:80     →     Service:80      →      Pod:8080
    (Your URL)          (Port Binding)        (Traffic Router)       (Load Balancer)        (Your App)
```

## Breaking Down Each Port Mapping

### 1. k3d Cluster Creation Command
```bash
k3d cluster create spring-cluster --port "8080:80@loadbalancer"
```

**What `8080:80@loadbalancer` means:**
- **8080** = Port on your host machine (localhost)
- **80** = Port inside the k3d load balancer container
- **@loadbalancer** = Target the load balancer container (not server nodes)

### 2. Service YAML Configuration
```yaml
spec:
  ports:
  - protocol: TCP
    port: 80        # Service listens on this port
    targetPort: 8080 # Forward to this port on pods
  type: LoadBalancer
```

**Key Points:**
- `port: 80` must match the k3d load balancer port (80)
- `targetPort: 8080` must match your Spring Boot container port

## Port Mapping Reference Table

| Stage | Component | Port | Configuration Location |
|-------|-----------|------|------------------------|
| 1 | Browser Request | 8080 | http://localhost:8080 |
| 2 | Docker Host | 8080 → 80 | k3d --port "8080:80@loadbalancer" |
| 3 | k3d Load Balancer | 80 | Internal k3d container |
| 4 | Kubernetes Service | 80 → 8080 | service.yaml (port: 80, targetPort: 8080) |
| 5 | Spring Boot Pod | 8080 | application.properties (server.port=8080) |

## The Connection Rule

```
Browser:8080 → Docker Host:8080 → k3d LoadBalancer:80 → Service:80 → Pod:8080
```

**Critical Point**: The service's `port: 80` MUST match the k3d load balancer's internal port (the second number in `8080:80`).

## Why This Specific Configuration?

### The Chain Must Connect:
- **k3d port mapping (8080:80)** - Creates the bridge from your host to k3d
- **Service port (80)** - Must match k3d's internal port
- **Service targetPort (8080)** - Must match your Spring Boot app port
- **Spring Boot port (8080)** - Your application's actual listening port

### Alternative Configurations:

```bash
# Option 1: Direct port mapping
k3d cluster create --port "8080:8080@loadbalancer"
# Then service.yaml: port: 8080, targetPort: 8080

# Option 2: Different host port
k3d cluster create --port "3000:80@loadbalancer"  
# Access via localhost:3000
# Service.yaml: port: 80, targetPort: 8080

# Option 3: Multiple services
k3d cluster create --port "8080:80@loadbalancer" --port "8443:443@loadbalancer"
# For HTTP and HTTPS services
```

## Why Not Just Use 8080 Everywhere?

You absolutely can! Here's an alternative approach:

```bash
# Create cluster with direct port mapping
k3d cluster create --port "8080:8080@loadbalancer"
```

```yaml
# service.yaml
ports:
- port: 8080      # Now matches k3d's internal port
  targetPort: 8080 # Still matches Spring Boot
```

## The @loadbalancer Part Explained

The `@loadbalancer` is crucial because k3d creates multiple containers:
- **Server nodes** (run your pods)
- **Load balancer** (routes external traffic)

By specifying `@loadbalancer`, you're telling k3d to bind the port to the load balancer container, which then forwards traffic to your services.

## Common Issues and Solutions

### ❌ Common Mistakes:
- Service port ≠ k3d port (80)
- Forgot @loadbalancer in k3d command
- Wrong targetPort in service
- Using ClusterIP instead of LoadBalancer

### ✅ Quick Debugging Commands:
```bash
# Check service status
kubectl get svc

# Test direct pod connection
kubectl port-forward deployment/spring-app-deployment 8081:8080

# Debug service details
kubectl describe svc spring-app-service

# Check pod logs
kubectl logs -l app=spring-app

# Verify endpoints
kubectl get endpoints
```

## Complete Working Example

### 1. Create k3d cluster:
```bash
k3d cluster create spring-cluster --port "8080:80@loadbalancer"
```

### 2. Service configuration (service.yaml):
```yaml
apiVersion: v1
kind: Service
metadata:
  name: spring-app-service
spec:
  selector:
    app: spring-app
  ports:
  - protocol: TCP
    port: 80        # Matches k3d internal port
    targetPort: 8080 # Matches Spring Boot port
  type: LoadBalancer
```

### 3. Spring Boot configuration (application.properties):
```properties
server.port=8080
```

### 4. Access from browser:
```
http://localhost:8080/
```

## Multiple Port Mappings

For more complex setups:

```bash
# Create cluster with multiple port mappings
k3d cluster create spring-cluster \
  --port "8080:80@loadbalancer" \
  --port "8443:443@loadbalancer" \
  --port "9090:9090@loadbalancer"
```

```yaml
# service.yaml for multiple ports
apiVersion: v1
kind: Service
metadata:
  name: spring-app-service
spec:
  selector:
    app: spring-app
  ports:
  - name: http
    protocol: TCP
    port: 80
    targetPort: 8080
  - name: https
    protocol: TCP
    port: 443
    targetPort: 8443
  - name: metrics
    protocol: TCP
    port: 9090
    targetPort: 9090
  type: LoadBalancer
```

## Troubleshooting Flow

If your service isn't accessible:

1. **Check k3d cluster**: `kubectl cluster-info`
2. **Verify service**: `kubectl get svc spring-app-service`
3. **Check endpoints**: `kubectl get endpoints spring-app-service`
4. **Test pods directly**: `kubectl port-forward pod/[pod-name] 8081:8080`
5. **Check logs**: `kubectl logs -l app=spring-app`

## Key Takeaway

🎯 **The port chain must be unbroken**: 
```
Browser → Docker → k3d → Service → Pod
```

Each arrow represents a port mapping that must be configured correctly:
- k3d cluster creation handles: Browser → Docker → k3d
- service.yaml handles: k3d → Service → Pod

The magic number that connects them is the **k3d internal port** (80 in our example), which must match the service's `port` field.