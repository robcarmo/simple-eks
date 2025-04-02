variable "name_prefix" {
  description = "Prefix for naming VPC resources"
  type        = string
}

variable "cluster_name_tag" {
  description = "The EKS cluster name, used for tagging subnets"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "num_azs" {
  description = "Number of Availability Zones to create subnets in"
  type        = number
  default     = 3
}

variable "tags" {
  description = "A map of additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}