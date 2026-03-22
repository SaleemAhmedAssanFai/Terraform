# AWS Infrastructure & CI/CD Pipeline

**Stack:** Terraform · AWS · Jenkins · Docker · SonarQube · Ansible · Grafana  
**Proof:** Screenshots Included  
**Status:** ✅ Complete

---

## 📌 Project Overview

This project provisions a full AWS cloud environment using Terraform and 
integrates a complete CI/CD pipeline with automated code quality checks, 
containerization, configuration management, and infrastructure monitoring.

The goal is to simulate a real-world DevOps workflow — from infrastructure 
provisioning to application deployment — using industry-standard tools.

---

## 🏗️ Architecture

| Component | Tool | Purpose |
|---|---|---|
| Infrastructure as Code | Terraform | Provision all AWS resources |
| Version Control | GitHub | Source code management |
| CI/CD Automation | Jenkins | Build, test, and deploy pipeline |
| Code Quality | SonarQube | Static code analysis |
| Containerization | Docker + ECR | Build and store Docker images |
| Configuration Management | Ansible | Install and configure software on EC2 |
| Monitoring | Grafana | Infrastructure observability dashboards |
| Cloud Provider | AWS | VPC, EC2, ECR, ALB, ASG |

---

## ☁️ AWS Infrastructure (Terraform)

### Resources Provisioned
- VPC with public and private subnets across multiple availability zones
- Internet Gateway and NAT Gateway
- Public and private route tables with associations
- Security groups for Jenkins, SonarQube, Ansible, Grafana, and the Application
- Network ACL (NACL)
- EC2 instances for Jenkins, SonarQube, Ansible, and Grafana
- Elastic IPs for each instance
- AWS ECR repository for Docker images
- Application Load Balancer (ALB)
- Auto Scaling Group (ASG) with Launch Template
- S3 backend for Terraform state management

---

## 📸 Phase 1 — Infrastructure Provisioning

> Provisioning the AWS environment using Terraform

**Step 1 — VPC and Networking**

<!-- Add your screenshot here -->
![VPC Setup](screenshots/vpc-setup.png)

*Created the VPC, subnets, internet gateway, NAT gateway, and route tables.*

---

**Step 2 — Security Groups**

<!-- Add your screenshot here -->
![Security Groups](screenshots/security-groups.png)

*Configured security groups for each tool with appropriate inbound/outbound rules.*

---

**Step 3 — EC2 Instances**

<!-- Add your screenshot here -->
![EC2 Instances](screenshots/ec2-instances.png)

*Launched EC2 instances for Jenkins, SonarQube, Ansible, and Grafana with 
user data scripts for automated installation.*

---

**Step 4 — Load Balancer & Auto Scaling**

<!-- Add your screenshot here -->
![ALB and ASG](screenshots/alb-asg.png)

*Configured the Application Load Balancer, target group, and Auto Scaling 
Group with a launch template for the application tier.*

---

**Step 5 — ECR Repository**

<!-- Add your screenshot here -->
![ECR Repository](screenshots/ecr-repo.png)

*Created an ECR repository with image scanning enabled to store Docker images.*

---

## 📸 Phase 2 — CI/CD Pipeline (Jenkins)

> Automating the build, test, and deployment workflow

**Step 6 — Jenkins Setup**

<!-- Add your screenshot here -->
![Jenkins Dashboard](screenshots/jenkins-dashboard.png)

*Jenkins installed and configured on EC2. Pipeline job created and connected 
to the GitHub repository.*

---

**Step 7 — SonarQube Code Quality Check**

<!-- Add your screenshot here -->
![SonarQube Analysis](screenshots/sonarqube-analysis.png)

*SonarQube integrated into the Jenkins pipeline to run static code analysis 
before the build proceeds.*

---

**Step 8 — Docker Build & Push to ECR**

<!-- Add your screenshot here -->
![Docker Build](screenshots/docker-build.png)

*Jenkins builds the Docker image and pushes it to the AWS ECR repository.*

---

**Step 9 — Ansible Configuration Management**

<!-- Add your screenshot here -->
![Ansible Playbook](screenshots/ansible-playbook.png)

*Ansible playbook triggered by Jenkins to configure EC2 instances and deploy 
the application container.*

---

## 📸 Phase 3 — Monitoring (Grafana)

> Observing infrastructure health and metrics

**Step 10 — Grafana Dashboard**

<!-- Add your screenshot here -->
![Grafana Dashboard](screenshots/grafana-dashboard.png)

*Grafana configured to monitor EC2 metrics and visualize infrastructure health 
across the environment.*

---

## 📂 Repository Structure
```
Terraform/
├── main.tf                  # All AWS resources
├── variables.tf             # Input variables
├── terraform.tfvars         # Variable values (not committed)
├── outputs.tf               # Output values
├── jenkins_install.sh       # Jenkins user data script
├── sonarqube_install.sh     # SonarQube user data script
├── ansible_install.sh       # Ansible user data script
├── grafana_install.sh       # Grafana user data script
└── screenshots/             # Project screenshots
```

---

## ▶️ How to Run
```bash
# 1. Clone the repository
git clone https://github.com/SaleemAhmedAssanFai/Terraform.git
cd Terraform

# 2. Set your AWS credentials as environment variables
export AWS_ACCESS_KEY_ID="your_access_key"
export AWS_SECRET_ACCESS_KEY="your_secret_key"

# 3. Initialize Terraform
terraform init

# 4. Preview the infrastructure plan
terraform plan

# 5. Deploy the infrastructure
terraform apply
```

---

[Back to Portfolio](https://github.com/SaleemAhmedAssanFai)
