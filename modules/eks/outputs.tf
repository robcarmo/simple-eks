output "cluster_id" {
  description = "The name/id of the EKS cluster"
  value       = aws_eks_cluster.demo.id
}

output "cluster_endpoint" {
  description = "The endpoint for your EKS Kubernetes API"
  value       = aws_eks_cluster.demo.endpoint
}

output "cluster_certificate_authority" {
  description = "Certificate authority data for the cluster"
  value       = aws_eks_cluster.demo.certificate_authority[0].data
}

output "worker_security_group_id" {
  description = "Security group ID attached to the EKS workers"
  value       = aws_security_group.node.id
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = var.vpc_id
}

output "subnet_ids" {
  description = "List of subnet IDs"
  value       = var.subnet_ids
}
