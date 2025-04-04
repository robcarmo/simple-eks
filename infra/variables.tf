variable "cluster-name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "cc-eks"
}

variable "kubernetes_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.27"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "node_instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 4
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}


variable "aws_region" {
  description = "The AWS region where resources will be created"
  type        = string
  default     = "us-east-1"  # You can change this to your desired default region
}

   variable "oidc_github_actions_role_arn" {
     description = "The ARN of the IAM role for GitHub Actions OIDC"
     type        = string
     default     = ""  # Default can be empty if you are passing it via environment variable
   }

   variable "admin_k8s_username" {
  description = "The desired Kubernetes username for the primary admin user."
  type        = string
  default     = "" # Or a sensible default if applicable
}

variable "admin_user_arns" {
  description = "A list of IAM User ARNs to grant cluster-admin access via system:masters."
  type        = string
  default     = ""#
}