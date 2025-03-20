locals {
  oidc_fully_qualified_subjects = "system:serviceaccount:*:*"
  oidc_provider_url            = replace(aws_eks_cluster.demo.identity[0].oidc[0].issuer, "https://", "")
}

resource "aws_iam_role" "eks_service_account_role" {
  name = "eks-service-account-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.eks.arn
      }
      Condition = {
        StringEquals = {
          "${local.oidc_provider_url}:sub" = local.oidc_fully_qualified_subjects
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_service_account_s3_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  role       = aws_iam_role.eks_service_account_role.name
}
