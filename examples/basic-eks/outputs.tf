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

output "vpc_id" {
  description = "VPC ID"
  value       = module.eks.vpc_id
}

output "subnet_ids" {
  description = "Subnet IDs"
  value       = module.eks.subnet_ids
}
