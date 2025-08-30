# Beginner's Guide: Kubernetes Learning Lab on 3 Proxmox VMs

## **🎯 What You'll Learn**
This guide walks you through creating a **real Kubernetes cluster** for learning purposes. You'll understand how Kubernetes works by building everything from scratch on your local Proxmox server.

## **📚 Learning Objectives**
- Understand Kubernetes cluster architecture
- Learn how container images are distributed
- Practice kubectl commands and YAML manifests
- Experience real cluster networking and scheduling
- Debug common Kubernetes issues

## **💻 Prerequisites**
- **Proxmox server** running on your local machine/homelab
- **Basic Linux knowledge** (SSH, basic commands)
- **Docker basics** (what containers are, basic commands)
- **Your development machine** with SSH access to Proxmox VMs

---

## **🏗️ Infrastructure Overview**
```
Your Dev Machine
       ↓ (SSH + kubectl)
┌─────────────────────────┐
│    Proxmox Server       │
│  ┌─────┐ ┌─────┐ ┌─────┐│
│  │ VM1 │ │ VM2 │ │ VM3 ││
│  │Master│ │Work1│ │Work2││
│  └─────┘ └─────┘ └─────┘│
└─────────────────────────┘
```

| Step | Phase | What You'll Do | Why It Matters | Learning Focus |
|------|-------|---------------|----------------|----------------|
| 1-7 | **🖥️ VM Setup** | Create 3 VMs in Proxmox | Learn infrastructure basics | VM management, networking |
| 8-12 | **🔧 System Prep** | Configure Linux on all VMs | Understand system requirements | Linux administration |
| 13-19 | **🐳 Docker Setup** | Install container runtime | Learn about container engines | Docker fundamentals |
| 20-27 | **☸️ K8s Install** | Install Kubernetes components | Understand K8s architecture | kubeadm, kubelet, kubectl |
| 28-40 | **🌐 Cluster Init** | Create and join cluster | Learn cluster formation | Master/worker concepts |
| 41-53 | **📦 Image Dist** | Manually distribute images | Understand image management | Container image lifecycle |
| 54-68 | **🚀 Deploy App** | Deploy your microservice | Learn Kubernetes resources | Pods, Services, Deployments |
| 69-85 | **🧪 Test & Scale** | Test and scale application | Practice cluster operations | Scaling, monitoring, updates |

---

## **Phase 1: VM Infrastructure (Steps 1-7)**

| Step | Action | Command/Location | Beginner Notes |
|------|--------|-----------------|----------------|
| 1 | Download Ubuntu template | Proxmox Web UI → Templates | **Why**: Consistent base for all VMs |
| 2 | Create VM template | 4 CPU, 8GB RAM, 50GB disk | **Learning**: Resource planning for K8s |
| 3 | Clone 3 VMs | k8s-master, k8s-worker1, k8s-worker2 | **Tip**: Use descriptive hostnames |
| 4 | Set static IPs | 192.168.1.100, .101, .102 | **Critical**: Nodes need fixed IPs |
| 5 | Configure SSH keys | Copy your public key to VMs | **Security**: Passwordless access |
| 6 | Start all VMs | Proxmox Web UI | **Check**: All VMs boot successfully |
| 7 | Test connectivity | `ssh user@192.168.1.100` | **Verify**: Can reach all 3 nodes |

### **🚨 Common Beginner Mistakes**
- **Dynamic IPs**: Don't use DHCP - Kubernetes needs stable IPs
- **Insufficient RAM**: 8GB minimum per VM, or pods won't schedule
- **Firewall blocking**: Disable UFW initially to avoid connection issues
- **SSH issues**: Test SSH access before proceeding

---

## **Phase 2: System Preparation (Steps 8-12)**

| Step | Action | Command | Why This Matters |
|------|--------|---------|-----------------|
| 8 | Update all systems | `apt update && apt upgrade -y` | **Learning**: Start with clean, updated systems |
| 9 | Install basic tools | `apt install -y curl wget git` | **Need**: Tools for downloading K8s components |
| 10 | Sync time across nodes | `timedatectl set-timezone UTC` | **Critical**: K8s requires time synchronization |
| 11 | Add hostnames to /etc/hosts | `192.168.1.100 k8s-master` | **Learning**: Internal name resolution |
| 12 | Disable swap | `swapoff -a && vim /etc/fstab` | **Critical**: Kubernetes REQUIRES swap disabled |

### **🎓 Learning Points**
- **Time sync**: Distributed systems need synchronized clocks
- **Hostname resolution**: Nodes must find each other by name
- **Swap disabled**: K8s manages memory, doesn't want OS swapping

---

## **Phase 3: Container Runtime (Steps 13-19)**

| Step | Action | Command | Learning Focus |
|------|--------|---------|----------------|
| 13 | Install Docker | `curl -fsSL https://get.docker.com -o get-docker.sh` | **Learn**: Container runtime concepts |
| 14 | Configure Docker daemon | Edit `/etc/docker/daemon.json` | **Understand**: Cgroup drivers |
| 15 | Start Docker service | `systemctl enable --now docker` | **Practice**: Linux service management |
| 16 | Add user to docker group | `usermod -aG docker $USER` | **Security**: Non-root Docker access |
| 17 | Test Docker | `docker run hello-world` | **Verify**: Container runtime works |
| 18 | Install Docker on all nodes | Repeat on worker1 and worker2 | **Consistency**: All nodes need runtime |
| 19 | Verify on all nodes | `docker ps` on each node | **Check**: Docker running everywhere |

### **📖 Docker daemon.json Configuration**
```json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
```

### **🎯 Why This Configuration**
- **Cgroup driver**: Must match kubelet (systemd)
- **Log rotation**: Prevent logs from filling disk
- **Storage driver**: Efficient overlay filesystem

---

## **Phase 4: Kubernetes Installation (Steps 20-27)**

| Step | Action | Command | Beginner Notes |
|------|--------|---------|----------------|
| 20 | Load kernel modules | `modprobe br_netfilter overlay` | **Learn**: Kernel modules for networking |
| 21 | Configure kernel parameters | Edit `/etc/sysctl.d/k8s.conf` | **Understand**: Network forwarding |
| 22 | Add Kubernetes repo | Google's official package repo | **Practice**: Adding external repositories |
| 23 | Install K8s components | `apt install -y kubelet kubeadm kubectl` | **Learn**: Core K8s tools |
| 24 | Hold package versions | `apt-mark hold kubelet kubeadm kubectl` | **Important**: Prevent auto-updates |
| 25 | Install on worker1 | Repeat steps 20-24 | **Consistency**: All nodes need K8s |
| 26 | Install on worker2 | Repeat steps 20-24 | **Patience**: This takes time |
| 27 | Verify installation | `kubeadm version` | **Check**: All tools installed |

### **📝 Kernel Parameters (/etc/sysctl.d/k8s.conf)**
```bash
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
```

### **🤔 What These Do**
- **Bridge filtering**: Allows iptables to see bridged traffic
- **IP forwarding**: Enables packet forwarding between containers

---

## **Phase 5: Cluster Creation (Steps 28-40)**

| Step | Action | Command | Learning Outcome |
|------|--------|---------|------------------|
| 28 | Initialize master | `kubeadm init --pod-network-cidr=10.244.0.0/16` | **Learn**: Cluster bootstrap process |
| 29 | **SAVE JOIN COMMAND** | Copy the `kubeadm join` output | **CRITICAL**: You need this for workers |
| 30 | Setup kubectl | Copy admin.conf to ~/.kube/config | **Learn**: Kubernetes authentication |
| 31 | Install network plugin | `kubectl apply -f flannel.yml` | **Understand**: Pod networking (CNI) |
| 32 | Check master status | `kubectl get nodes` | **Should see**: Master in Ready state |
| 33 | Join worker1 | Run saved join command | **Learn**: Node registration |
| 34 | Join worker2 | Run saved join command | **Practice**: Cluster expansion |
| 35 | Verify cluster | `kubectl get nodes` | **Success**: 3 nodes Ready |
| 36 | Check system pods | `kubectl get pods -n kube-system` | **Learn**: System components |
| 37 | Copy kubeconfig to dev machine | `scp k8s-master:~/.kube/config ~/.kube/config-k8s` | **Remote**: Control cluster from dev machine |
| 38 | Configure kubectl context | `export KUBECONFIG=~/.kube/config-k8s` | **Practice**: Remote cluster management |
| 39 | Test remote access | `kubectl get nodes` from dev machine | **Verify**: Remote control works |
| 40 | Explore cluster | `kubectl cluster-info` | **Learn**: Cluster endpoints |

### **🚨 Critical Step: Save Join Command**
When you run `kubeadm init`, you'll see output like:
```bash
kubeadm join 192.168.1.100:6443 --token abc123.xyz789 \
  --discovery-token-ca-cert-hash sha256:abcd1234...
```
**COPY THIS ENTIRE COMMAND** - you need it for steps 33-34!

### **🎓 What Just Happened**
- **Master node**: Runs the Kubernetes control plane (API server, scheduler, etc.)
- **Worker nodes**: Run your application pods
- **CNI plugin**: Enables pod-to-pod networking across nodes
- **kubeconfig**: Your "key" to access the cluster

---

## **Phase 6: Application Development (Steps 41-44)**

| Step | Action | File | Learning Focus |
|------|--------|------|----------------|
| 41 | Create project structure | Organize code and manifests | **Best practice**: Separate concerns |
| 42 | Write Spring Boot app | Java REST API with JSON | **Development**: Real application |
| 43 | Create Dockerfile | Container definition | **Containerization**: App packaging |
| 44 | Test locally (optional) | `mvn spring-boot:run` | **Debugging**: Test before containerizing |

### **📁 Recommended Project Structure**
```
my-microservice/
├── src/                    # Your Java code
├── k8s/                   # Kubernetes manifests
│   ├── namespace.yaml
│   ├── deployment.yaml
│   └── service.yaml
├── Dockerfile             # Container definition
├── pom.xml               # Maven configuration
└── README.md             # Documentation
```

---

## **Phase 7: Image Distribution (Steps 45-53)**

| Step | Action | Command | Why We Do This |
|------|--------|---------|----------------|
| 45 | Build image on dev machine | `docker build -t my-app:v1 .` | **Learn**: Container image creation |
| 46 | Export image to file | `docker save -o my-app-v1.tar my-app:v1` | **Understand**: Image portability |
| 47 | Copy to master | `scp my-app-v1.tar user@k8s-master:/tmp/` | **Distribution**: Moving images around |
| 48 | Copy to worker1 | `scp my-app-v1.tar user@k8s-worker1:/tmp/` | **Replication**: All nodes need image |
| 49 | Copy to worker2 | `scp my-app-v1.tar user@k8s-worker2:/tmp/` | **Consistency**: Same image everywhere |
| 50 | Load on master | `ssh k8s-master "docker load -i /tmp/my-app-v1.tar"` | **Import**: Make image available |
| 51 | Load on worker1 | `ssh k8s-worker1 "docker load -i /tmp/my-app-v1.tar"` | **Availability**: Pod can run anywhere |
| 52 | Load on worker2 | `ssh k8s-worker2 "docker load -i /tmp/my-app-v1.tar"` | **Scheduling**: Kubernetes flexibility |
| 53 | Verify images | `ssh <node> "docker images"` | **Confirm**: Image exists on all nodes |

### **🤖 Automation Script for Image Distribution**
```bash
#!/bin/bash
# distribute-image.sh - Makes your life easier!

IMAGE="my-microservice:v1"
NODES=("k8s-master" "k8s-worker1" "k8s-worker2")
USER="ubuntu"

echo "🏗️  Building image..."
docker build -t $IMAGE .

echo "💾 Saving image to tar..."
docker save -o ${IMAGE//[:\/]/-}.tar $IMAGE

echo "📤 Distributing to nodes..."
for node in "${NODES[@]}"; do
    echo "  → Copying to $node..."
    scp ${IMAGE//[:\/]/-}.tar $USER@$node:/tmp/
    
    echo "  → Loading on $node..."
    ssh $USER@$node "docker load -i /tmp/${IMAGE//[:\/]/-}.tar && rm /tmp/${IMAGE//[:\/]/-}.tar"
done

rm ${IMAGE//[:\/]/-}.tar
echo "✅ Distribution complete!"
```

### **🎓 What You're Learning**
- **Image lifecycle**: Build → Save → Transfer → Load
- **Distribution challenges**: Getting images to all nodes
- **Why registries exist**: This manual process doesn't scale
- **Container portability**: Same image runs anywhere

---

## **Phase 8: Kubernetes Deployment (Steps 54-68)**

| Step | Action | File | Learning Objective |
|------|--------|------|-------------------|
| 54 | Create namespace | `namespace.yaml` | **Isolation**: Separate your apps |
| 55 | Create ConfigMap | `configmap.yaml` | **Configuration**: External app config |
| 56 | **Critical: Set imagePullPolicy** | `imagePullPolicy: Never` | **Important**: Don't pull from internet |
| 57 | Create Deployment | `deployment.yaml` | **Learn**: Replica management |
| 58 | Create Service | `service.yaml` | **Networking**: Internal load balancing |
| 59 | Create Ingress | `ingress.yaml` | **External access**: HTTP routing |
| 60 | Apply namespace | `kubectl apply -f k8s/namespace.yaml` | **Practice**: Kubectl commands |
| 61 | Apply ConfigMap | `kubectl apply -f k8s/configmap.yaml` | **Order matters**: Dependencies first |
| 62 | Apply Deployment | `kubectl apply -f k8s/deployment.yaml` | **Main event**: Deploy your app |
| 63 | Apply Service | `kubectl apply -f k8s/service.yaml` | **Networking**: Make pods accessible |
| 64 | Check pods | `kubectl get pods -n my-app` | **Monitor**: Watch pods start |
| 65 | Check services | `kubectl get svc -n my-app` | **Networking**: Verify service creation |
| 66 | Describe deployment | `kubectl describe deployment -n my-app` | **Debug**: Understand what happened |
| 67 | Check pod distribution | `kubectl get pods -o wide -n my-app` | **Scheduling**: Pods across nodes |
| 68 | View logs | `kubectl logs -l app=my-app -n my-app` | **Debugging**: Application output |

### **🚨 Critical Configuration**
```yaml
# deployment.yaml - Most important parts
spec:
  containers:
  - name: my-microservice
    image: my-microservice:v1
    imagePullPolicy: Never  # 🚨 CRITICAL: Don't try to pull from registry
    ports:
    - containerPort: 8080
```

### **🎯 Key Learning Concepts**
- **Namespace**: Logical separation of resources
- **Deployment**: Manages replica pods
- **Service**: Stable networking for pods
- **ConfigMap**: External configuration
- **imagePullPolicy: Never**: Use local images only

---

## **Phase 9: Testing & Verification (Steps 69-77)**

| Step | Action | Command | What You're Learning |
|------|--------|---------|---------------------|
| 69 | Get service info | `kubectl get svc -n my-app` | **Networking**: How to access services |
| 70 | Port forward for testing | `kubectl port-forward svc/my-service 8080:80 -n my-app` | **Access**: Local testing method |
| 71 | Test basic endpoint | `curl http://localhost:8080/api/` | **Verification**: App is working |
| 72 | Test JSON API | `curl http://localhost:8080/api/users` | **Functionality**: REST API works |
| 73 | Test POST request | `curl -X POST -H "Content-Type: application/json" -d '{"name":"test"}' http://localhost:8080/api/users` | **CRUD**: Create operations |
| 74 | Check pod logs | `kubectl logs -f -l app=my-app -n my-app` | **Debugging**: See application logs |
| 75 | Test from different nodes | Direct node access via NodePort | **Networking**: External access |
| 76 | Monitor resources | `kubectl top nodes && kubectl top pods -n my-app` | **Monitoring**: Resource usage |
| 77 | Test load balancing | Multiple requests, check pod names in response | **Distribution**: Load balancing works |

### **🧪 Testing Commands**
```bash
# Basic health check
curl http://localhost:8080/api/health

# Load balancing test - should show different pod names
for i in {1..10}; do
  curl -s http://localhost:8080/api/ | grep podName
done

# JSON API test
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{"name": "John Doe", "email": "john@example.com"}'
```

---

## **Phase 10: Scaling & Operations (Steps 78-85)**

| Step | Action | Command | Learning Goal |
|------|--------|---------|---------------|
| 78 | Scale up application | `kubectl scale deployment my-app --replicas=5 -n my-app` | **Scaling**: Horizontal scaling |
| 79 | Watch pods start | `kubectl get pods -w -n my-app` | **Monitoring**: Real-time changes |
| 80 | Verify distribution | `kubectl get pods -o wide -n my-app` | **Scheduling**: Pods spread across nodes |
| 81 | Scale down | `kubectl scale deployment my-app --replicas=2 -n my-app` | **Resource management**: Reduce resources |
| 82 | Update application | Build v2, distribute, update deployment | **Updates**: Rolling deployments |
| 83 | Check rollout status | `kubectl rollout status deployment/my-app -n my-app` | **Deployment**: Monitor updates |
| 84 | Rollback if needed | `kubectl rollout undo deployment/my-app -n my-app` | **Recovery**: Undo changes |
| 85 | Clean up | `kubectl delete namespace my-app` | **Cleanup**: Remove resources |

---

## **🚨 Important Considerations for Beginners**

### **💰 Resource Management**
```yaml
# Always set resource limits in production
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```
**Why**: Prevents one pod from consuming all node resources

### **🔒 Security Considerations**
- **Don't run as root**: Use non-root user in containers
- **Network policies**: Implement when you understand basics
- **RBAC**: Role-based access control for production
- **Image scanning**: Check for vulnerabilities

### **🐛 Common Beginner Issues**

#### **Pod Stuck in Pending**
```bash
kubectl describe pod <pod-name> -n my-app
# Look for: insufficient resources, node selector issues
```

#### **ImagePullBackOff Error**
```bash
# Check imagePullPolicy is set to Never
kubectl describe pod <pod-name> -n my-app
```

#### **Service Not Accessible**
```bash
# Check service endpoints
kubectl get endpoints -n my-app
```

#### **Pods Not Distributed**
```bash
# Check node resources
kubectl describe nodes
kubectl top nodes
```

### **🎓 Learning Progression**
1. **Week 1**: Get cluster running, deploy simple apps
2. **Week 2**: Understand services, networking, scaling
3. **Week 3**: ConfigMaps, secrets, persistent storage
4. **Week 4**: Monitoring, logging, troubleshooting

### **📚 Next Steps After This Lab**
1. **Add persistent storage** (PersistentVolumes)
2. **Implement monitoring** (Prometheus/Grafana)
3. **Add ingress controller** for HTTP routing
4. **Learn about Helm** for package management
5. **Study StatefulSets** for databases
6. **Explore service mesh** (Istio) for advanced networking

### **🛠️ Useful Learning Commands**
```bash
# Explore your cluster
kubectl get all --all-namespaces
kubectl describe node <node-name>
kubectl get events --sort-by='.lastTimestamp'

# Debug applications
kubectl logs -f deployment/my-app -n my-app
kubectl exec -it <pod-name> -n my-app -- /bin/bash
kubectl port-forward pod/<pod-name> 8080:8080 -n my-app

# Monitor resources
kubectl top nodes
kubectl top pods --all-namespaces
watch kubectl get pods -n my-app
```

### **🎯 Success Metrics**
You'll know you're successful when:
- ✅ All 3 nodes show "Ready" status
- ✅ Pods are distributed across multiple nodes
- ✅ Your application responds to HTTP requests
- ✅ You can scale pods up and down
- ✅ Rolling updates work without downtime
- ✅ You can troubleshoot issues using kubectl

### **🚀 Why This Approach for Learning**
- **Real cluster experience**: Not a simulation
- **Understand fundamentals**: How images, networking, scheduling work
- **Build confidence**: Hands-on problem solving
- **Production insights**: Real challenges you'll face
- **Cost effective**: No cloud bills while learning

Remember: **This is a learning environment**. Make mistakes, experiment, break things, and learn from the experience. The goal is understanding, not perfection!