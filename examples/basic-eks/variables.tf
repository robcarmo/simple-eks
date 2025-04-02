variable "aws_region" {
  type = string
  default = "us-east-1"
}

variable "cluster_name" {
  type = string
  default = "demo-eks"
}

variable "availability_zones" {
  type = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "cluster_endpoint_allowed_cidrs" {
  type = list(string)
  default = ["0.0.0.0/0"]
}

variable "map_admin_user_arn" {
  type = string
}
