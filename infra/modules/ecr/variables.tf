variable "repository_name" {
  description = "The name of the ECR repository."
  type        = string
}

variable "image_tag_mutability" {
  description = "Sets the image tag mutability setting for the repository. If true, tags are mutable; if false, tags are immutable."
  type        = bool
  default     = false
}

variable "scan_images_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository."
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to assign to the ECR repository."
  type        = map(string)
  default     = {}
}
