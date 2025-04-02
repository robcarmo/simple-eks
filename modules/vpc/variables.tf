variable "name_prefix" {
  description = "Prefix for naming VPC resources (e.g., 'my-cluster'). Used to create unique names."
  type        = string
}

variable "cluster_name_tag" {
  description = "The EKS cluster name, used for tagging subnets ('kubernetes.io/cluster/<cluster_name_tag>'). Should match the cluster name."
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Must be a valid IPv4 CIDR block (e.g., 10.0.0.0/16)."
  }
}

variable "num_azs" {
  description = "Number of Availability Zones to create public subnets in. Should match the number of AZs desired for the EKS cluster."
  type        = number
  default     = 3 # Defaulting to 3 for high availability

  validation {
    condition     = var.num_azs >= 2 && var.num_azs <= 4 # Common practical limits
    error_message = "Number of AZs must typically be between 2 and 4 for EKS."
  }
}

variable "tags" {
  description = "A map of additional tags to apply to all resources created by this module."
  type        = map(string)
  default     = {}
}