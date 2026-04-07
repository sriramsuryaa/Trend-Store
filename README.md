# Trend Store - Complete DevOps Project

A modern DevOps repository that deploys the Trend Store static web app with Docker, Jenkins CI/CD, Terraform infrastructure, Amazon EKS, and monitoring.

## 📋 Project Overview

This repository implements a full DevOps workflow for the Trend Store application:

- **Infrastructure as Code** with Terraform
- **Docker containerization** for the application and Jenkins
- **CI/CD pipeline** with Jenkins
- **Kubernetes deployment** on Amazon EKS
- **Monitoring stack** using Prometheus and Grafana

## 🏗️ Architecture & Technology Stack

### Infrastructure Layer
- **Cloud Provider**: AWS
- **IaC Tool**: Terraform
- **Orchestration**: Amazon EKS
- **Bootstrap script**: `terraform/init.sh`

### Application Layer
- **Frontend**: Static HTML/CSS/JS served by Nginx
- **Web Server**: Nginx based on `nginx:alpine`
- **App config**: `nginx.conf`
- **Container image**: built from `Dockerfile`

### CI/CD Layer
- **CI/CD Tool**: Jenkins
- **Pipeline**: `Jenkinsfile`
- **Jenkins compose**: `Jenkins/docker-compose.yaml`
- **Deploy commands**: `kubectl apply -f k8s/`

### Monitoring Layer
- **Docker Compose**: `monitoring/docker-compose.yaml`
- **Prometheus config**: `monitoring/prometheus.yaml`
- **Exporter**: Nginx Prometheus exporter
- **Dashboard**: Grafana

## 📁 Project Structure

```
Trend-Store/
├── .dockerignore
├── Dockerfile
├── Jenkinsfile
├── Jenkins/
│   └── docker-compose.yaml
├── app/
│   └── ...
├── k8s/
│   ├── deployment.yaml
│   └── service.yaml
├── monitoring/
│   ├── docker-compose.yaml
│   └── prometheus.yaml
├── nginx.conf
├── terraform/
│   └── init.sh
└── README.md
```

## 🚀 Quick Start

### Prerequisites

- AWS account and AWS CLI configured
- Terraform installed
- Git installed
- Docker installed
- Docker Compose installed
- `kubectl` installed
- `eksctl` installed
- DockerHub account

### 1. Clone repository

```bash
git clone https://github.com/your-username/trend-store.git
cd trend-store
```

### 2. Deploy infrastructure with Terraform

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

**Expected Output:**
```
jenkins_public_ip = "YOUR_EC2_PUBLIC_IP"
jenkins_url = "http://YOUR_EC2_PUBLIC_IP:8080"
```

### 3. Build and test locally

```bash
docker build -t trend-store:local .
docker run -d --name trend-store-local -p 8080:80 trend-store:local
curl -I http://localhost:8080/health
```

### 4. Create DockerHub repository

Push the image to your DockerHub repository:

```bash
docker tag trend-store:local <username>/trend-store:latest
docker push <username>/trend-store:latest
```

### 5. Create Kubernetes registry secret

```bash
kubectl create secret docker-registry regcred \
  --docker-username=<username> \
  --docker-password=<token>
```

### 6. Install required tools

```bash
# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" \
  | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin/

# Install docker-compose
sudo apt-get update
sudo apt-get install -y docker-compose
```

### 7. Create EKS cluster

```bash
eksctl create cluster --name TS-APP-PRD \
  --region ap-south-1 \
  --nodegroup-name TS-APP-PRD-NG \
  --nodes 2 \
  --instance-types t3.small \
  --instance-name TS-APP-PRD-EKS
```

### 8. Start Jenkins

The repository contains a Jenkins Compose file under `Jenkins/docker-compose.yaml`:

```yaml
services:
  jenkins:
    image: jenkins/jenkins:lts
    container_name: jenkins
    network_mode: host
    restart: unless-stopped
    volumes:
      - /var/lib/jenkins/:/var/jenkins_home
      - /etc/localtime:/etc/localtime:ro
      - /etc/timezone:/etc/timezone:ro
      - /var/run/docker.sock:/var/run/docker.sock
      - /usr/bin/docker:/usr/bin/docker
      - /usr/local/bin/kubectl:/usr/local/bin/kubectl
      - /home/ubuntu/.aws:/var/jenkins_home/.aws:ro
```

Run Jenkins with:

```bash
cd Jenkins
docker-compose up -d
```

### 9. Deploy the application to Kubernetes

```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

### 10. Start the monitoring stack

```bash
cd monitoring
docker-compose up -d
```

The monitoring stack uses:
- `monitoring/docker-compose.yaml`
- `monitoring/prometheus.yaml`

## 📌 Notes on current repository files

- `Dockerfile` builds the Trend Store app with `nginx:alpine`
- `nginx.conf` configures the app and exposes `/health` and `/stub_status`
- `Jenkinsfile` defines the CI/CD pipeline to build, push, and deploy the app
- `Jenkins/docker-compose.yaml` starts Jenkins with Docker and kubectl mounted
- `terraform/init.sh` bootstraps Docker and starts Jenkins with host networking
- `k8s/deployment.yaml` and `k8s/service.yaml` deploy the app to Kubernetes
- `monitoring/docker-compose.yaml` starts Prometheus, Grafana, and the Nginx exporter
- `monitoring/prometheus.yaml` configures Prometheus scraping

## 🔄 CI/CD Pipeline

The Jenkins pipeline performs these stages:

1. Build Docker image
2. Tag and push image to DockerHub
3. Deploy Kubernetes manifests
4. Restart and validate the `trend-store` deployment

### Jenkins pipeline details

- Uses `dockerhub-credentials` for DockerHub authentication
- Uses `trend-store-cluster` kubeconfig file credential for cluster access
- Cleans up local Docker images after completion

## ☸️ Kubernetes Deployment

### Deployment Manifest

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: trend-store
spec:
  replicas: 2
  selector:
    matchLabels:
      app: trend-store
  template:
    metadata:
      labels:
        app: trend-store
    spec:
      imagePullSecrets:
        - name: regcred
      containers:
        - name: trend-store
          image: sriramsuryaa/trend-store-prod:latest
          ports:
            - containerPort: 80
```

### Service Manifest

```yaml
apiVersion: v1
kind: Service
metadata:
  name: trend-store
spec:
  selector:
    app: trend-store
  type: LoadBalancer
  ports:
    - name: http
      protocol: TCP
      port: 80
      targetPort: 80
```

### Deployment Strategy

- Rolling updates for zero downtime
- Two replicas for availability
- LoadBalancer service for external access
- Nginx health endpoint used by monitoring and readiness checks

## 📝 Credits

**Trend Store Application**: Developed by [Vennil Avadhoot](https://github.com/Vennilavanguvi/Trend.git)

**DevOps Infrastructure & Automation**: Terraform, Jenkins CI/CD pipeline, Kubernetes deployment, monitoring stack, and cloud infrastructure setup implemented by me.
