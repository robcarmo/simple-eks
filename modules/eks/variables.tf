variable "cluster-name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "terraform-eks"
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
  type        = string
  description = "ID of VPC where EKS cluster will be created"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for EKS cluster"
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
