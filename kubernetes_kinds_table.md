# Kubernetes Resource Types (Kinds) Reference

## Core Workload Resources

| Kind | Purpose | When to Use |
|------|---------|-------------|
| **Pod** | Smallest deployable unit; contains one or more containers | Testing/debugging individual containers; rarely used directly in production |
| **Deployment** | Manages replica sets and rolling updates for stateless applications | Web apps, APIs, microservices - most common workload type |
| **ReplicaSet** | Ensures specified number of pod replicas are running | Usually managed by Deployments; rarely created directly |
| **StatefulSet** | Manages stateful applications with persistent identity and storage | Databases, message queues, applications needing stable network identity |
| **DaemonSet** | Ensures one pod runs on each node (or subset of nodes) | Log collectors, monitoring agents, node-level services |
| **Job** | Runs pods to completion for batch processing | Data processing, backups, one-time migrations |
| **CronJob** | Runs jobs on a time-based schedule | Scheduled backups, periodic cleanup, batch reports |

## Service & Networking Resources

| Kind | Purpose | When to Use |
|------|---------|-------------|
| **Service** | Provides stable network endpoint for accessing pods | Load balancing traffic to your applications |
| **Endpoints** | Tracks IP addresses of pods backing a service | Usually auto-managed; manual control of service targets |
| **Ingress** | HTTP/HTTPS routing rules for external access | Web applications needing domain-based routing |
| **NetworkPolicy** | Controls network traffic between pods | Security isolation, micro-segmentation |

## Configuration & Storage Resources

| Kind | Purpose | When to Use |
|------|---------|-------------|
| **ConfigMap** | Stores non-sensitive configuration data | Application settings, environment variables, config files |
| **Secret** | Stores sensitive data (passwords, tokens, keys) | Database credentials, API keys, TLS certificates |
| **PersistentVolume (PV)** | Cluster-wide storage resource | Providing storage that outlives pods |
| **PersistentVolumeClaim (PVC)** | Request for storage by a user/pod | When applications need persistent storage |
| **StorageClass** | Defines types of storage available | Different storage tiers (SSD, HDD, cloud storage) |
| **Volume** | Storage attached to a pod | Temporary storage, shared data between containers |

## Security & Access Control

| Kind | Purpose | When to Use |
|------|---------|-------------|
| **ServiceAccount** | Identity for pods to access Kubernetes API | When pods need to interact with Kubernetes resources |
| **Role** | Defines permissions within a namespace | Namespace-specific access control |
| **ClusterRole** | Defines cluster-wide permissions | Cluster-wide access control |
| **RoleBinding** | Grants Role permissions to users/groups/service accounts | Applying namespace permissions |
| **ClusterRoleBinding** | Grants ClusterRole permissions cluster-wide | Applying cluster-wide permissions |
| **PodSecurityPolicy** | Controls security aspects of pod specifications | Enforcing security policies (deprecated in v1.21+) |
| **SecurityContextConstraints** | OpenShift equivalent of PodSecurityPolicy | Security policies in OpenShift |

## Scaling & Performance

| Kind | Purpose | When to Use |
|------|---------|-------------|
| **HorizontalPodAutoscaler (HPA)** | Automatically scales pods based on metrics | Auto-scaling based on CPU, memory, or custom metrics |
| **VerticalPodAutoscaler (VPA)** | Automatically adjusts resource requests/limits | Right-sizing resource allocation |
| **PodDisruptionBudget (PDB)** | Ensures minimum number of pods during disruptions | Maintaining availability during cluster maintenance |

## Advanced Workload Resources

| Kind | Purpose | When to Use |
|------|---------|-------------|
| **CustomResourceDefinition (CRD)** | Defines new custom resource types | Extending Kubernetes with custom resources |
| **Operator** | Manages complex applications using custom resources | Database operators, monitoring stack management |
| **MutatingAdmissionWebhook** | Modifies resources during creation/update | Injecting sidecars, modifying resource specs |
| **ValidatingAdmissionWebhook** | Validates resources during creation/update | Enforcing policies, resource validation |

## Cluster Management Resources

| Kind | Purpose | When to Use |
|------|---------|-------------|
| **Namespace** | Logical isolation of resources within a cluster | Multi-tenancy, environment separation, resource organization |
| **Node** | Represents a worker machine in the cluster | Cluster management (usually auto-managed) |
| **Event** | Records cluster events and state changes | Debugging, auditing, monitoring |
| **ComponentStatus** | Status of cluster components | Health checking cluster components |
| **ResourceQuota** | Limits resource consumption in a namespace | Resource management, cost control |
| **LimitRange** | Enforces minimum/maximum resource constraints | Preventing resource abuse, setting defaults |

## Service Mesh & Advanced Networking

| Kind | Purpose | When to Use |
|------|---------|-------------|
| **VirtualService** | Traffic routing rules (Istio) | Advanced traffic management in service mesh |
| **DestinationRule** | Policies for traffic to a service (Istio) | Load balancing, circuit breakers in service mesh |
| **Gateway** | Configures load balancer for HTTP/TCP traffic (Istio) | Service mesh ingress/egress |
| **PeerAuthentication** | Defines authentication policies (Istio) | mTLS policies in service mesh |

## Monitoring & Observability

| Kind | Purpose | When to Use |
|------|---------|-------------|
| **ServiceMonitor** | Defines monitoring targets for Prometheus | Prometheus-based monitoring setup |
| **PodMonitor** | Defines pod-level monitoring for Prometheus | Direct pod monitoring with Prometheus |
| **PrometheusRule** | Defines alerting and recording rules | Setting up alerts and metrics aggregation |

## Application Lifecycle

| Kind | Purpose | When to Use |
|------|---------|-------------|
| **Helm Chart** | Package manager for Kubernetes applications | Deploying complex applications with dependencies |
| **Kustomization** | Template-free way to customize YAML configurations | Configuration management without templating |

## Common Usage Patterns

### Basic Web Application Stack
- **Namespace** → **Deployment** → **Service** → **Ingress**
- **ConfigMap** + **Secret** for configuration
- **PVC** if persistent storage needed

### Database Deployment
- **StatefulSet** → **Service** → **PVC**
- **Secret** for credentials
- **NetworkPolicy** for access control

### Batch Processing
- **Job** or **CronJob**
- **ConfigMap** for job configuration
- **PVC** for data persistence

### Monitoring Setup
- **DaemonSet** for node agents
- **ServiceMonitor** for metrics collection
- **ConfigMap** for monitoring configuration