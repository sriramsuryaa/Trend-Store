# Trend Store - Complete DevOps Project

A comprehensive DevOps project demonstrating modern cloud-native application deployment with Infrastructure as Code (IaC), CI/CD pipelines, and container orchestration.

## 📋 Project Overview

This project implements a complete DevOps workflow for a Trend Store e-commerce application, featuring:

- **Infrastructure as Code** using Terraform
- **Containerized Application** with Docker
- **CI/CD Pipeline** using Jenkins
- **Container Orchestration** with Kubernetes (EKS)
- **Automated Deployments** with zero-downtime updates

## 🏗️ Architecture & Technology Stack

### Infrastructure Layer
- **Cloud Provider**: AWS (ap-south-2 region)
- **IaC Tool**: Terraform v1.14.8
- **Virtual Network**: VPC with public/private subnets
- **Compute**: EC2 instance (Ubuntu 22.04) with Docker
- **Container Runtime**: Docker with host networking
- **Orchestration**: Amazon EKS (Kubernetes)

### Application Layer
- **Frontend**: Static HTML/CSS/JavaScript (Nginx-based)
- **Web Server**: Nginx Alpine
- **Container Registry**: DockerHub
- **Load Balancing**: AWS LoadBalancer Service

### CI/CD Layer
- **CI/CD Tool**: Jenkins (Docker container)
- **Version Control**: Git
- **Build Tool**: Docker
- **Deployment Tool**: kubectl
- **Artifact Storage**: DockerHub Registry

### Monitoring & Security
- **Access Control**: IAM Roles and Security Groups
- **Encryption**: EBS volume encryption
- **Network Security**: VPC isolation with security groups

## 📁 Project Structure

```
Trend-Store/
├── app/                    # Static web application files
│   ├── index.html
│   └── assets/
├── Dockerfile             # Docker image definition
├── Jenkinsfile           # CI/CD pipeline definition
├── k8s/                  # Kubernetes manifests
│   ├── deployment.yaml   # Application deployment
│   └── service.yaml      # LoadBalancer service
├── Terraform/            # Infrastructure as Code
│   ├── main.tf          # Core infrastructure
│   ├── variables.tf     # Configuration variables
│   ├── outputs.tf       # Output values
│   └── init.sh          # EC2 initialization script
└── README.md            # This documentation
```

## 🚀 Quick Start

### Prerequisites

1. **AWS Account** with appropriate permissions
2. **AWS CLI** configured with credentials
3. **Terraform** v1.14.8+ installed
4. **Git** for version control
5. **DockerHub** account for container registry

### Step 1: Clone Repository

```bash
git clone https://github.com/your-username/trend-store.git
cd trend-store
```

### Step 2: Deploy Infrastructure

```bash
cd Terraform
terraform init
terraform plan
terraform apply
```

**Expected Output:**
```
jenkins_public_ip = "13.127.XXX.XXX"
jenkins_url = "http://13.127.XXX.XXX:8080"
```

### Step 3: Access Jenkins

1. Open browser: `http://YOUR_PUBLIC_IP:8080`
2. Get initial admin password:
   ```bash
   # SSH into Jenkins server
   ssh ubuntu@YOUR_PUBLIC_IP

   # Get Jenkins password
   sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
   ```
3. Complete Jenkins setup wizard

### Step 4: Configure Jenkins Pipeline

1. **Install Plugins:**
   - Docker Pipeline
   - Kubernetes CLI
   - Git

2. **Add Credentials:**
   - `dockerhub-credentials`: DockerHub username + token
   - `kubeconfig`: EKS cluster kubeconfig file

3. **Create Pipeline Job:**
   - Name: `trend-store-cicd`
   - Type: Pipeline
   - SCM: Git (this repository)
   - Script Path: `Jenkinsfile`

### Step 5: Configure EKS (Optional)

If you want to deploy to EKS instead of EC2:

```bash
# Create EKS cluster (example)
eksctl create cluster --name trend-store-cluster --region ap-south-2

# Get kubeconfig
aws eks update-kubeconfig --name trend-store-cluster --region ap-south-2
```

## 🔧 Infrastructure Details

### VPC Configuration
- **CIDR Block**: 10.0.0.0/16
- **Public Subnet**: 10.0.1.0/24 (auto-assigns public IPs)
- **Internet Gateway**: Enables internet access
- **Route Tables**: Public routing for internet connectivity

### EC2 Instance
- **AMI**: Ubuntu 22.04 LTS (Canonical)
- **Instance Type**: t3.medium (2 vCPU, 4GB RAM)
- **Storage**: 50GB gp3 EBS (encrypted)
- **Networking**: Public subnet with auto-assigned public IP

### Security Groups
- **SSH Access**: Port 22 (0.0.0.0/0 - restrict in production)
- **Jenkins Access**: Port 8080 (0.0.0.0/0)
- **Egress**: All outbound traffic allowed

### IAM Configuration
- **EC2 Role**: Basic permissions for EC2 operations
- **Instance Profile**: Allows EC2 to assume the role

## 🐳 Application Containerization

### Dockerfile Analysis

```dockerfile
FROM nginx:alpine                    # Lightweight base image
LABEL maintainer="developer@trendstore.com"
COPY app/. /usr/share/nginx/html/.   # Static files
EXPOSE 80                           # Nginx default port
```

### Docker Image Details
- **Base Image**: nginx:alpine (small footprint)
- **Application**: Static HTML/CSS/JS e-commerce site
- **Port**: 80 (internal), mapped to host port 8080
- **Registry**: DockerHub (sriramsuryaa/trend-store-dev)

## 🔄 CI/CD Pipeline

### Pipeline Stages

1. **Git Checkout**
   ```groovy
   checkout scm  // Pulls latest code
   ```

2. **Docker Build**
   ```groovy
   docker build -t image:${BUILD_NUMBER} .
   docker tag image:${BUILD_NUMBER} image:latest
   ```

3. **Docker Push**
   ```groovy
   docker login -u $USER -p $TOKEN
   docker push image:${BUILD_NUMBER}
   docker push image:latest
   ```

4. **Deploy to EKS**
   ```groovy
   kubectl apply -f k8s/
   kubectl rollout status deployment/trend-store
   ```

### Environment Variables
- `DOCKERHUB_CREDENTIALS`: Registry authentication
- `DOCKER_IMAGE_NAME`: Repository name
- `DOCKER_IMAGE_TAG`: Build versioning
- `KUBECONFIG_CREDENTIALS`: Cluster access

### Post-Build Actions
- **Success**: Display service URL
- **Failure**: Show pod status and logs
- **Always**: Clean up Docker images

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
    spec:
      containers:
      - name: trend-store
        image: sriramsuryaa/trend-store-dev:latest
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
  - port: 80
    targetPort: 80
```

### Deployment Strategy
- **Rolling Updates**: Zero-downtime deployments
- **Replica Count**: 2 pods for high availability
- **Load Balancer**: AWS ELB for external access
- **Health Checks**: Automatic pod health monitoring

## 📊 Monitoring & Troubleshooting

### Application Monitoring

```bash
# Check pod status
kubectl get pods -l app=trend-store

# View application logs
kubectl logs -l app=trend-store

# Check service endpoints
kubectl get svc trend-store

# Monitor deployment rollout
kubectl rollout status deployment/trend-store
```

### Jenkins Monitoring

```bash
# Check Jenkins container
docker ps | grep jenkins

# View Jenkins logs
docker logs jenkins

# Access Jenkins CLI
docker exec -it jenkins bash
```

### Infrastructure Monitoring

```bash
# Check EC2 instance
aws ec2 describe-instances --instance-ids YOUR_INSTANCE_ID

# View CloudWatch logs (if configured)
aws logs tail /aws/jenkins/trendstore --follow
```

## 🔒 Security Considerations

### Network Security
- **VPC Isolation**: Private resources in isolated network
- **Security Groups**: Minimal required port access
- **Encrypted Storage**: EBS volumes with encryption

### Access Control
- **IAM Roles**: Least privilege principle
- **SSH Keys**: Secure key-based authentication
- **Jenkins Credentials**: Secure credential storage

### Container Security
- **Non-root User**: Jenkins runs as jenkins user
- **Minimal Base Images**: Alpine Linux for smaller attack surface
- **Regular Updates**: Keep base images updated

## 🧪 Testing the Deployment

### Manual Testing

1. **Access Application:**
   ```bash
   curl http://YOUR_LOADBALANCER_URL
   ```

2. **Check Application Health:**
   ```bash
   kubectl exec -it $(kubectl get pods -l app=trend-store -o jsonpath='{.items[0].metadata.name}') -- curl localhost
   ```

3. **Load Testing:**
   ```bash
   # Simple load test
   for i in {1..10}; do curl -s http://YOUR_LOADBALANCER_URL > /dev/null & done
   ```

### Automated Testing

Add to Jenkinsfile for comprehensive testing:

```groovy
stage('Test') {
    steps {
        sh '''
            # Unit tests (if applicable)
            # Integration tests
            # Load tests
            echo "Running tests..."
        '''
    }
}
```

## 🚀 Scaling & Optimization

### Horizontal Scaling

```bash
# Scale deployment
kubectl scale deployment trend-store --replicas=5

# Auto-scaling (requires HPA)
kubectl autoscale deployment trend-store --cpu-percent=70 --min=2 --max=10
```

### Performance Optimization

1. **Resource Limits:**
   ```yaml
   resources:
     requests:
       memory: "128Mi"
       cpu: "100m"
     limits:
       memory: "256Mi"
       cpu: "200m"
   ```

2. **Caching:** Implement CDN for static assets
3. **Database:** Add persistent storage if needed

## 🛠️ Customization & Extensions

### Adding Environment Variables

```yaml
env:
- name: NODE_ENV
  value: "production"
- name: API_URL
  value: "https://api.trendstore.com"
```

### Adding ConfigMaps/Secrets

```yaml
envFrom:
- configMapRef:
    name: trend-store-config
- secretRef:
    name: trend-store-secrets
```

### Multi-Environment Deployment

```groovy
// Add to Jenkinsfile
stage('Deploy to Staging') {
    when {
        branch 'develop'
    }
    steps {
        // Deploy to staging environment
    }
}

stage('Deploy to Production') {
    when {
        branch 'main'
    }
    steps {
        // Deploy to production environment
    }
}
```

## 📈 Cost Optimization

### Infrastructure Costs
- **EC2**: t3.medium (~$30/month)
- **EBS**: 50GB gp3 (~$5/month)
- **EKS**: Per pod pricing
- **Load Balancer**: ~$20/month

### Cost Saving Tips
1. **Use Spot Instances** for non-production
2. **Scheduled Scaling** - reduce replicas at night
3. **Right-size Resources** based on actual usage
4. **Clean up Resources** when not in use

## 🔄 Backup & Recovery

### Application Backup
```bash
# Backup Jenkins data
docker run --rm -v jenkins_data:/data -v $(pwd):/backup alpine tar czf /backup/jenkins-backup.tar.gz -C /data .
```

### Infrastructure Backup
```bash
# Terraform state backup
terraform state pull > terraform.tfstate.backup

# AMI creation for EC2
aws ec2 create-image --instance-id YOUR_INSTANCE_ID --name "jenkins-backup-$(date +%Y%m%d)"
```

## 📚 Learning Outcomes

This project demonstrates:

- **Infrastructure as Code** principles
- **Container orchestration** with Kubernetes
- **CI/CD pipeline** implementation
- **Cloud-native** application deployment
- **DevOps best practices** and automation
- **Monitoring and troubleshooting** techniques

## 🤝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/new-feature`
3. Commit changes: `git commit -am 'Add new feature'`
4. Push to branch: `git push origin feature/new-feature`
5. Create Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support & Issues

### Common Issues & Solutions

1. **Jenkins not accessible:**
   - Check security group allows port 8080
   - Verify Docker container is running: `docker ps`

2. **Pipeline fails at Docker push:**
   - Verify DockerHub credentials in Jenkins
   - Check repository permissions

3. **EKS deployment fails:**
   - Validate kubeconfig credentials
   - Check EKS cluster status: `aws eks describe-cluster`

### Getting Help

- **Documentation**: Check AWS, Docker, Kubernetes docs
- **Logs**: Use `kubectl logs` and Jenkins console output
- **Community**: Stack Overflow, DevOps forums

---

**Built with ❤️ for DevOps learning and demonstration**

*Last updated: April 2026*