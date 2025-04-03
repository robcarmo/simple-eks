variable "cluster-name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "cc-eks"
}

variable "kubernetes_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.27"
  
  validation {
    condition     = can(regex("^1\\.(2[3-7]|[3-9][0-9])$", var.kubernetes_version))
    error_message = "Kubernetes version must be 1.23 or higher."
  }
}

variable "vpc_id" {
  description = "The ID of the VPC where the cluster will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where the cluster will be deployed"
  type        = list(string)
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
  description = "The AWS region to deploy resources in."
  type        = string
  # Default removed or kept if you want a fallback for local runs
}

variable "oidc_github_actions_role_arn" {
  description = "The ARN of the IAM Role created for GitHub Actions OIDC."
  type        = string
  # No default needed when using TF_VAR_
}

variable "admin_user_arns" {
  description = "A list of IAM User ARNs to grant cluster-admin access via system:masters."
  type        = list(string) # Terraform can usually parse the JSON array string into a list
  default     = [] # Keep default empty if no users should be mapped by default
}

