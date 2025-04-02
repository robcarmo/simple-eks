variable "cluster-name" {
  type = string
}

variable "kubernetes_version" {
  type    = string
  default = "1.27"
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "node_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "node_max_size" {
  type    = number
  default = 4
}

variable "node_min_size" {
  type    = number
  default = 1
}
