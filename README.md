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
│   │   └── vpc/ # Networking module
│   │       ├── main.tf # VPC, subnets, routing
│   │       ├── variables.tf # Networking inputs
│   │       └── outputs.tf # Networking outputs
│   ├── outputs.tf
│   └── variables.tf
```

## Key Features
- **EKS Cluster Creation**: Managed control plane with configurable Kubernetes versions (1.23+)
- **Worker Node Groups**: Auto-scaling groups with launch templates
- **Secure Networking**: VPC with public subnets across 3 AZs
- **Kubernetes Integration**: Helm-managed namespace/pod/service resources
- **IAM Authentication**: Automated token generation for cluster access (via `kubectl`)

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

You can customize the deployment by modifying the `values.yaml` file in the Helm chart directory. This file contains default values for the deployment, including the namespace, image, and service type.

## Best Practices

- Use separate Terraform workspaces for environments.
- Enable AWS provider version pinning (>= 5.0).
- Regularly rotate IAM credentials.
- Use t3 instance types for cost-effective worker nodes.
- Maintain Kubernetes version parity between control plane and worker nodes.

## Last Updated

Last updated: April 2025 (Terraform 1.5+, AWS Provider 5.0+, Helm 3.0+)