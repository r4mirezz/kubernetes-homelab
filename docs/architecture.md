# Homelab architecture

## Infrastructure
- AWS region: eu-north-1
- Two Ubuntu EC2 instances in the same VPC and subnet
- Kubernetes v1.37.2 with containerd 2.2.1
- Flannel VXLAN Pod networking

## Nodes
| Node | Private IP | Purpose |
|---|---|---|
| Control plane | 172.31.14.159 | Cluster management |
| Worker | 172.31.1.110 | Application Pods |

The control plane has a NoSchedule taint.
Both Nginx replicas currently run on the worker.

## Network access
- SSH restricted to the administrator's public IP.
- Worker accesses the control-plane API over TCP 6443.
- Control plane accesses the worker kubelet over TCP 10250.
- Flannel traffic crosses nodes over UDP 8472.
- Application Service uses ClusterIP.

## Verified paths
- Temporary Pod to application Service using cluster DNS.
- API server to worker kubelet for application logs.
- Control-plane host to worker Pod over the Pod network.

## Limitations
- One control plane: no control-plane high availability.
- One worker: both application replicas share a failure point.
- Both instances are in one Availability Zone.
- The storage exercise uses a local volume tied to the
  control-plane node; it does not automatically move to the worker.
- Persistence is not a backup.
