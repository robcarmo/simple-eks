# Terraform EKS Module

This repository contains Terraform configurations for deploying an Amazon EKS cluster with integrated networking and Kubernetes resource management. It now also includes a Helm chart for managing Kubernetes resources.

## Repository Structure
```
├── helm/
│   └── demo-service/ # Helm chart for deploying the demo service
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/ # Kubernetes manifest templates
├── infra/
│   ├── main.tf # Core configuration
│   ├── modules/
│   │   ├── eks/ # EKS cluster module
│   │   │   ├── main.tf # Security groups, IAM roles, EKS cluster
│   │   │   ├── variables.tf # Module inputs
│   │   │   └── outputs.tf # Module outputs
│   │   ├── vpc/ # Networking module
│   │   │   ├── main.tf # VPC, subnets, routing
│   │   │   ├── variables.tf # Networking inputs
│   │   │   └── outputs.tf # Networking outputs
│   ├── outputs.tf
│   └── variables.tf
```

## Key Features
- **EKS Cluster Creation**: Managed control plane with configurable Kubernetes versions (1.23+)
- **Worker Node Groups**: Auto-scaling groups with launch templates
- **Secure Networking**: VPC with public subnets across 3 AZs
- **Kubernetes Integration**: Helm-managed namespace/pod/service resources
- **IAM Authentication**: Automated token generation for cluster access (via `kubectl`)

## Prerequisites

### OIDC Account for GitHub Actions

To deploy this cluster via GitHub Actions without using AWS access keys, you need to set up an OIDC account with the necessary permissions. Follow these steps:

1. **Create an IAM Role for GitHub Actions OIDC**:
   - Go to the IAM console in AWS.
   - Create a new role with the following trust policy:
     ```json
     {
       "Version": "2012-10-17",
       "Statement": [
         {
           "Effect": "Allow",
           "Principal": {
             "Federated": "arn:aws:iam::YOUR_AWS_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
           },
           "Action": "sts:AssumeRoleWithWebIdentity",
           "Condition": {
             "StringEquals": {
               "token.actions.githubusercontent.com:sub": "repo:YOUR_GITHUB_USERNAME/YOUR_REPOSITORY_NAME:*"
             }
           }
         }
       ]
     }
     ```
   - Attach the necessary policies to this role to allow it to create and manage EKS clusters and other AWS resources.

2. **Set the Role ARN in GitHub Secrets**:
   - Go to your GitHub repository settings.
   - Under "Secrets and variables" -> "Actions", create a new secret named `OIDC_ROLE_ARN` and set its value to the ARN of the IAM role you created.
   - You do not need to set AWS access keys (AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY) as the OIDC role will handle authentication.

## Quick Start

1. Clone the repository:
   ```shell
   git clone https://github.com/robcarmo/simple-eks.git
   cd simple-eks/infra
   ```

2. Initialize Terraform:
   ```shell
   terraform init
   ```

3. Review the plan:
   ```shell
   terraform plan
   ```

4. Apply the configuration:
   ```shell
   terraform apply
   ```

5. Deploy the Helm chart:
   ```shell
   cd ../helm/demo-service
   helm install demo-service .
   ```

## Helm Chart Usage

The Helm chart located in `helm/demo-service` can be used to deploy the demo service to your EKS cluster. 

### Installation

To install the Helm chart, ensure you have Helm installed and configured to communicate with your EKS cluster. Then run:

```shell
helm install demo-service ./demo-service
```

### Configuration

You can customize the deployment by modifying the `values.yaml` file in the Helm chart directory. This file contains default values for the deployment, including the namespace, image, and service configurations.

## Modules

### VPC Module

The VPC module (`modules/vpc`) handles the creation of a Virtual Private Cloud (VPC), subnets, and routing. Ensure that you do not create the VPC more than once to avoid duplication.

### EKS Module

The EKS module (`modules/eks`) is responsible for setting up the EKS cluster, including security groups, IAM roles, and node groups.

### ECR Module

The ECR module (`modules/ecr`) sets up an Elastic Container Registry (ECR) repository for storing Docker images used by the demo service.

## Variables and Outputs

### Variables

The `variables.tf` file defines various input variables used to customize the Terraform configuration, such as cluster name, Kubernetes version, VPC CIDR block, and node instance types.

### Outputs

The `outputs.tf` file provides the outputs of the Terraform configuration, including the EKS cluster ID, endpoint, and ECR repository URL and ARN.

## Best Practices

- Use separate Terraform workspaces for environments.
- Enable AWS provider version pinning (>= 5.0).
- Regularly rotate IAM credentials.
- Use t3 instance types for cost-effective worker nodes.
- Maintain Kubernetes version parity between control plane and worker nodes.

## References

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html)

## Last Updated

Last updated: April 2025 (Terraform 1.5+, AWS Provider 5.0+, Helm 3.0+)