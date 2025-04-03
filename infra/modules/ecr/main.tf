resource "aws_ecr_repository" "ecr_repo" {
  name                 = var.repository_name
  image_tag_mutability = var.image_tag_mutability ? "MUTABLE" : "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = var.scan_images_on_push
  }

  lifecycle {
    ignore_changes = [/* list attributes you want Terraform to ignore */]
  }

  tags = var.tags
}
