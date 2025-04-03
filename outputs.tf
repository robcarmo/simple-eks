output "cluster_certificate_authority" {
  description = "Base64 encoded certificate data required to communicate with cluster"
  value       = module.eks.cluster_certificate_authority
}

output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = module.ecr.repository_url
}

output "ecr_repository_arn" {
  description = "The ARN of the ECR repository"
  value       = module.ecr.repository_arn
}
