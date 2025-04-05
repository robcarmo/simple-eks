output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

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

output "eks_node_role_arn" {
description = "ARN of the IAM role for worker nodes"
value       = module.eks.node_role_arn
}