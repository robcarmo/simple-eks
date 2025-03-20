resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = <<YAML
- rolearn: ${aws_iam_role.demo-node.arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
- rolearn: ${aws_iam_role.breno-node.arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
YAML

    mapUsers = <<YAML
- userarn: arn:aws:iam::149399235178:user/robaws
  username: robaws
  groups:
    - system:masters
YAML
  }

  depends_on = [
    aws_eks_cluster.demo,
    aws_autoscaling_group.demo,
    aws_autoscaling_group.breno
  ]
}