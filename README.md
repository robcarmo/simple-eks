# Terraform EKS Module

This repository contains Terraform configurations for deploying an Amazon EKS cluster with a demo Node.js application using Helm.

## Prerequisites

- AWS CLI installed and configured
- Terraform 1.5+
- kubectl
- Helm 3.0+

## AWS Access Keys Setup

1. Create AWS Access Keys in the AWS Console
2. Configure AWS CLI:
```bash
aws configure
```
Enter your AWS Access Key ID and Secret Access Key when prompted.

## Deployment Steps

1. Initialize Terraform:
```bash
cd infra/
terraform init
```

2. Deploy infrastructure:
```bash
terraform plan
terraform apply
```

3. Configure kubectl:
```bash
aws eks update-kubeconfig --name eks-cluster --region us-east-1
```

4. Deploy application:
```bash
cd ../helm/demo-service
helm install demo-service . -n demo-service --create-namespace
```

## Testing the Deployment

1. Check the service status:
```bash
kubectl get svc demo-service-svc -n demo-service
```

2. Wait for the LoadBalancer EXTERNAL-IP to be available

3. Test the application:
```bash
curl http://<EXTERNAL-IP>:8080
```

Note: The application runs on port 8080. Make sure this port is allowed in the security groups.

## Last Updated

Last updated: April 2025 (Terraform 1.5+, AWS Provider 5.0+, Helm 3.0+)