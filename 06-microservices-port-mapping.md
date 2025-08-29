# Real World Microservices Port Distribution

## k3d Cluster Creation Command

```bash
k3d cluster create microservices-cluster \
  --port "8080:80@loadbalancer" \
  --port "8081:81@loadbalancer" \
  --port "8082:82@loadbalancer" \
  --port "8083:83@loadbalancer" \
  --port "8084:84@loadbalancer" \
  --port "8085:85@loadbalancer" \
  --port "8086:86@loadbalancer" \
  --port "8087:87@loadbalancer" \
  --port "8088:88@loadbalancer" \
  --port "8089:89@loadbalancer"
```

## Port Distribution Table

| Service Name | Browser URL | Docker Host | k3d LoadBalancer | Kubernetes Service | Spring Boot Pod |
|--------------|-------------|-------------|------------------|-------------------|-----------------|
| API Gateway | localhost:8080 | 8080 → 80 | 80 | port: 80 → targetPort: 8080 | 8080 |
| User Service | localhost:8081 | 8081 → 81 | 81 | port: 81 → targetPort: 8080 | 8080 |
| Product Service | localhost:8082 | 8082 → 82 | 82 | port: 82 → targetPort: 8080 | 8080 |
| Order Service | localhost:8083 | 8083 → 83 | 83 | port: 83 → targetPort: 8080 | 8080 |
| Payment Service | localhost:8084 | 8084 → 84 | 84 | port: 84 → targetPort: 8080 | 8080 |
| Inventory Service | localhost:8085 | 8085 → 85 | 85 | port: 85 → targetPort: 8080 | 8080 |
| Notification Service | localhost:8086 | 8086 → 86 | 86 | port: 86 → targetPort: 8080 | 8080 |
| Analytics Service | localhost:8087 | 8087 → 87 | 87 | port: 87 → targetPort: 8080 | 8080 |
| Report Service | localhost:8088 | 8088 → 88 | 88 | port: 88 → targetPort: 8080 | 8080 |
| Config Service | localhost:8089 | 8089 → 89 | 89 | port: 89 → targetPort: 8080 | 8080 |

## Key Patterns

### 1. **Browser Access**: Each service gets its own port (8080-8089)
- API Gateway: `http://localhost:8080`
- User Service: `http://localhost:8081`
- Product Service: `http://localhost:8082`
- etc.

### 2. **k3d Internal Ports**: Sequential (80, 81, 82, ...)
- Simple to remember and manage
- Each service gets its unique internal port

### 3. **Spring Boot Pods**: All use port 8080
- Standard Spring Boot default
- Consistent across all microservices
- Easy to maintain

## Sample Service YAML Files

### API Gateway Service (gateway-service.yaml)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: api-gateway-service
spec:
  selector:
    app: api-gateway
  ports:
  - port: 80
    targetPort: 8080
  type: LoadBalancer
```

### User Service (user-service.yaml)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: user-service
spec:
  selector:
    app: user-service
  ports:
  - port: 81
    targetPort: 8080
  type: LoadBalancer
```

### Product Service (product-service.yaml)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: product-service
spec:
  selector:
    app: product-service
  ports:
  - port: 82
    targetPort: 8080
  type: LoadBalancer
```

## Alternative Approach: Using Single Port with Path-Based Routing

For production-like setup, you might prefer using an API Gateway with path-based routing:

### Single k3d Port Setup
```bash
k3d cluster create microservices-cluster --port "8080:80@loadbalancer"
```

### Path-Based Access
| Service | URL Path | Internal Service |
|---------|----------|------------------|
| API Gateway | localhost:8080/ | Routes to other services |
| User Service | localhost:8080/users | ClusterIP service |
| Product Service | localhost:8080/products | ClusterIP service |
| Order Service | localhost:8080/orders | ClusterIP service |

## Quick Reference Commands

### Deploy all services:
```bash
kubectl apply -f gateway-service.yaml
kubectl apply -f user-service.yaml
kubectl apply -f product-service.yaml
# ... repeat for all services
```

### Check all services:
```bash
kubectl get svc
```

### Test all endpoints:
```bash
curl localhost:8080  # API Gateway
curl localhost:8081  # User Service
curl localhost:8082  # Product Service
# ... etc
```

## Best Practices

1. **API Gateway Pattern**: Use port 8080 for API Gateway, others for direct service access
2. **Consistent Internal Ports**: All Spring Boot apps use 8080 internally
3. **Sequential External Ports**: Easy to remember (8080, 8081, 8082...)
4. **Documentation**: Always document which port belongs to which service
5. **Environment Variables**: Use env vars in your services to reference other services by name, not port