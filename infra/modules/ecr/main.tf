# --- START OF FILE infra/modules/ecr/main.tf ---

# Data source is now commented out
# data "aws_ecr_repository" "ecr_repo" {
#   name = var.repository_name
# }

# Resource block is now active (uncommented)
resource "aws_ecr_repository" "ecr_repo" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = var.scan_images_on_push
  }

  tags = var.tags
}
# --- END OF FILE infra/modules/ecr/main.tf ---