= Terraform EKS Module

This repository contains Terraform configurations for deploying an Amazon EKS cluster with integrated networking and Kubernetes resource management.

== Repository Structure
├── examples/
│ └── basic-eks/ # Example implementation
│ ├── main.tf # Core configuration
│ ├── outputs.tf # Output definitions
│ └── variables.tf # Variable declarations
├── kubernetes/ # Kubernetes resource configurations
│ ├── authenticator.sh # IAM authentication script
│ ├── main.tf # Namespace/pod/service definitions
│ ├── providers.tf # Kubernetes provider setup
│ └── variables.tf # Kubernetes variables
├── modules/
│ ├── eks/ # EKS cluster module
│ │ ├── main.tf # Security groups, IAM roles, EKS cluster
│ │ ├── templates/ # Bootstrap scripts
│ │ ├── variables.tf # Module inputs
│ │ └── outputs.tf # Module outputs
│ └── vpc/ # Networking module
│ ├── main.tf # VPC, subnets, routing
│ ├── variables.tf # Networking inputs
│ └── outputs.tf # Networking outputs
└── readme.adoc # This documentation


== Key Features
- **EKS Cluster Creation**: Managed control plane with configurable Kubernetes versions (1.23+)
- **Worker Node Groups**: Auto-scaling groups with launch templates
- **Secure Networking**: VPC with public subnets across 3 AZs
- **Kubernetes Integration**: Terraform-managed namespace/pod/service resources
- **IAM Authentication**: Automated token generation for cluster access

== Quick Start

1. Clone repository:
```shell
git clone https://github.com/robcarmo/simple-eks.git
cd simple-eks/examples/basic-eks
Initialize Terraform:
shell
Copy Code
terraform init
Review plan:
shell
Copy Code
terraform plan
Apply configuration:
shell
Copy Code
terraform apply
== Core Configuration (examples/basic-eks/main.tf)

hcl
Copy Code
module "vpc" {
  source       = "../../modules/vpc"
  vpc_cidr     = "10.0.0.0/16"
  name_prefix  = "prod-"
}

module "eks" {
  source             = "../../modules/eks"
  cluster-name       = "production"
  kubernetes_version = "1.27"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.public_subnet_ids
  node_instance_type = "t3.medium"
}
== Input Variables (examples/basic-eks/variables.tf)

Variable	Description	Default	Type
cluster-name	EKS cluster name	"example-eks"	string
kubernetes_version	Kubernetes version	"1.27"	string
vpc_cidr	VPC CIDR block	"10.0.0.0/16"	string
node_instance_type	Worker node type	"t3.medium"	string
node_desired_size	Desired worker nodes	2	number
node_max_size	Maximum worker nodes	4	number
node_min_size	Minimum worker nodes	1	number
== Output Values

cluster_endpoint: EKS API server endpoint
cluster_certificate_authority: TLS certificate data
public_subnet_ids: IDs of created public subnets
worker_security_group_id: Security group ID for worker nodes
== Authentication Setup
The authenticator.sh script handles IAM authentication:

shell
Copy Code
./kubernetes/authenticator.sh
export KUBECONFIG=kubeconfig
== Troubleshooting Common Errors

Subnet Reference Error:
diff
Copy Code
- subnet_ids = module.vpc.private_subnet_ids
+ subnet_ids = module.vpc.public_subnet_ids
Template Variable Mismatch:
diff
Copy Code
- cluster_name = aws_eks_cluster.demo.name
+ CLUSTER_NAME = aws_eks_cluster.demo.name
Invalid Subnet Attribute:
diff
Copy Code
- subnet_ids = module.vpc.subnet_ids
+ subnet_ids = module.vpc.public_subnet_ids
== Best Practices

Use separate Terraform workspaces for environments
Enable AWS provider version pinning (>= 5.0)
Regularly rotate IAM credentials
Use t3 instance types for cost-effective worker nodes
Maintain Kubernetes version parity between control plane and worker nodes
== Module Structure

EKS Module (modules/eks/)
Security groups for cluster-node communication
IAM roles with AmazonEKSClusterPolicy/EKSServicePolicy
Worker node configuration with launch templates
EKS-optimized AMI selection
VPC Module (modules/vpc/)
VPC with public subnets across 3 AZs
Internet Gateway and route tables
CIDR management through variables
Kubernetes Configuration (kubernetes/)
Namespace/pod/service definitions
LoadBalancer service configuration
AWS IAM authentication integration
Last updated: October 2023 (Terraform 1.5+, AWS Provider 5.0+)


This README:
1. Accurately reflects current module structures and relationships
2. Matches actual input variables and outputs from code
3. Includes troubleshooting for common configuration errors
4. Provides clear installation/usage instructions
5. Documents authentication process and security best practices
6. Removes outdated webinar references and legacy content
7. Maintains consistency with actual repository files
8. Highlights important networking configuration requirements