# Production-Grade GitOps-Driven Microservices Demo

A production-oriented DevOps project demonstrating how to deploy and operate a containerized microservices application on **AWS EKS** using **Terraform, Docker, Kubernetes, GitHub Actions and Argo CD**, with HTTPS-based routing and monitoring through **Prometheus and Grafana**.

This project is built as a practical demonstration of the DevOps workflow required for provisioning, deployment automation, traffic management and observability.

---

## Architecture

```text
                         GitHub
                           |
                     GitHub Actions
                           |
                    Docker Image Build
                           |
                           v
                     Container Image
                           |
                           v
                         Argo CD
                           |
                        GitOps
                           |
                           v
                    +-------------+
                    |   AWS EKS   |
                    |             |
                    | Microservices
                    | Argo CD     |
                    | Prometheus  |
                    | Grafana     |
                    +------+------+
                           |
                     Gateway API
                           |
                           v
                      AWS ALB
                           |
                  HTTPS / ACM Certificate
                           |
                       Route 53
                           |
                           v
                         Users
```

---

## Tech Stack

* **AWS**
* **Terraform** — infrastructure provisioning
* **Amazon EKS** — Kubernetes platform
* **Docker** — containerization
* **Kubernetes** — application orchestration
* **Helm** — Kubernetes package management
* **GitHub Actions** — CI
* **Argo CD** — GitOps continuous delivery
* **AWS Load Balancer Controller / Gateway API** — external traffic routing
* **ExternalDNS** — Route 53 DNS management
* **AWS Certificate Manager (ACM)** — HTTPS/TLS
* **Prometheus** — metrics
* **Grafana** — dashboards

---

## Project Components

### Application

A containerized microservices demo application running on Kubernetes.

### GitOps

Argo CD manages Kubernetes deployments from Git and continuously reconciles the desired state with the EKS cluster.

```text
Git Repository
      |
      v
    Argo CD
      |
      v
    EKS
```

### External Access

Multiple applications are exposed through the same AWS Application Load Balancer using Gateway API `HTTPRoute`.

Examples:

```text
https://app.rdhiaditya.space
https://argocd.rdhiaditya.space
https://grafana.rdhiaditya.space
https://prometheus.rdhiaditya.space
```

ExternalDNS manages the corresponding Route 53 records and ACM provides HTTPS certificates.

---

## Observability

Prometheus and Grafana are deployed in the `monitoring` namespace.

```text
Kubernetes
    |
    v
Prometheus
    |
    v
Grafana
```

Prometheus is exposed through an HTTPRoute and AWS ALB.

The Prometheus backend was validated using:

```bash
kubectl -n monitoring exec -it \
prometheus-kube-prometheus-stack-prometheus-0 \
-c prometheus -- \
wget -qO- http://127.0.0.1:9090/-/ready
```

and externally:

```bash
curl -vk https://prometheus.rdhiaditya.space/-/ready
```

Result:

```text
HTTP/2 200

Prometheus Server is Ready.
```

Grafana is also exposed through the same ALB:

```text
https://grafana.rdhiaditya.space
```

---

## AWS Load Balancer & Kubernetes Routing

The project uses Kubernetes Gateway API with an AWS Application Load Balancer.

Example:

```text
Client
  |
  v
Route 53
  |
  v
AWS ALB
  |
  v
Gateway
  |
  v
HTTPRoute
  |
  v
Kubernetes Service
  |
  v
Pod
```

For Prometheus:

```text
HTTPRoute
    |
    v
kube-prometheus-stack-prometheus:9090
    |
    v
10.0.3.66:9090
```

The AWS TargetGroupBinding was also validated and the Prometheus target was confirmed **healthy**.

---

## Troubleshooting

One of the practical debugging scenarios involved Prometheus and Grafana HTTPRoutes continuously producing:

```text
Failed to update route status

status.parents[0].conditions:
Required value
```

Instead of assuming the application was broken, the traffic path was investigated layer by layer:

```text
DNS
 ↓
TLS
 ↓
ALB
 ↓
Target Group
 ↓
Gateway
 ↓
HTTPRoute
 ↓
Service
 ↓
EndpointSlice
 ↓
Pod
```

The Prometheus Service had a valid endpoint:

```text
10.0.3.66:9090
```

and the AWS target group reported:

```text
State: healthy
```

External requests subsequently confirmed that Prometheus was reachable and healthy.

This demonstrates the troubleshooting approach used in the project rather than relying only on Kubernetes controller logs.

---

## Repository Structure

```text
.
├── terraform/
├── application/
├── argocd/
├── observability/
├── .github/
└── README.md
```

---

## Running the Project

### Provision infrastructure

```bash
terraform init
terraform plan
terraform apply
```

### Configure EKS

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name <cluster-name>
```

### Verify cluster

```bash
kubectl get nodes
kubectl get pods -A
```

### Verify Gateway API

```bash
kubectl get gateway -A
kubectl get httproute -A
```

### Verify monitoring

```bash
kubectl get pods -n monitoring
kubectl get svc -n monitoring
```

---

## What This Project Demonstrates

* Infrastructure as Code with Terraform
* AWS EKS and Kubernetes
* Docker-based deployments
* GitHub Actions CI
* GitOps with Argo CD
* Kubernetes Gateway API
* AWS Application Load Balancer
* Route 53 + ExternalDNS
* ACM HTTPS
* Prometheus monitoring
* Grafana dashboards
* End-to-end production troubleshooting

---

## Assignment Mapping

| 8Byte.ai Requirement        | Project                           |
| --------------------------- | --------------------------------- |
| Infrastructure Provisioning | Terraform + AWS + EKS             |
| Deployment Automation       | GitHub Actions + Argo CD          |
| Monitoring                  | Prometheus + Grafana              |
| Documentation               | This README + Challenges Document |

> The project focuses primarily on DevOps infrastructure, deployment and observability rather than application logic, as requested in the assignment.
