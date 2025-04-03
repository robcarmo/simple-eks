data "aws_ecr_repository" "ecr_repo" {
  name = var.repository_name
}


// resource "aws_ecr_repository" "ecr_repo" {
//   name                 = var.repository_name
//   image_tag_mutability = var.image_tag_mutability ? "MUTABLE" : "IMMUTABLE"

//   image_scanning_configuration {
//     scan_on_push = var.scan_images_on_push
//   }

//   tags = var.tags
// }
