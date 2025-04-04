# --- START OF FILE infra/modules/ecr/outputs.tf ---

output "repository_url" {
  description = "The URL of the ECR repository."
  # Corrected: Reference the resource instead of the data source
  value       = aws_ecr_repository.ecr_repo.repository_url
}

output "repository_arn" {
  description = "The ARN of the ECR repository."
  # Corrected: Reference the resource instead of the data source
  value       = aws_ecr_repository.ecr_repo.arn
}

output "repository_name" {
  description = "The name of the ECR repository."
  # Corrected: Reference the resource instead of the data source
  value       = aws_ecr_repository.ecr_repo.name
}
# --- END OF FILE infra/modules/ecr/outputs.tf ---