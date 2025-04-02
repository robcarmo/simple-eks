output "endpoint" {
  value = aws_eks_cluster.demo.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.demo.certificate_authority[0].data
}

output "cluster_name" {
  value = aws_eks_cluster.demo.name
}

output "cluster_security_group_id" {
  value = aws_security_group.cluster.id
}
