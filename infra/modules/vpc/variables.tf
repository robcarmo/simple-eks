variable "name_prefix" {
  description = "Prefix for naming VPC resources"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "num_azs" {
  description = "Number of Availability Zones to use"
  type        = number
  default     = 3
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}