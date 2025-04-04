provider "aws" {
  region = "us-east-1"
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster-name]
    command     = "aws"
  }
}

module "vpc" {
  source          = "./modules/vpc"
  vpc_cidr        = var.vpc_cidr
  name_prefix     = "${var.cluster-name}"
}

module "eks" {
  source = "./modules/eks"
  cluster-name = var.cluster-name
  aws_region = var.aws_region
  kubernetes_version = var.kubernetes_version
  vpc_id = module.vpc.vpc_id
  oidc_github_actions_role_arn = var.oidc_github_actions_role_arn
  admin_user_arns = var.admin_user_arns
  admin_k8s_username = var.admin_k8s_username
  subnet_ids = module.vpc.public_subnet_ids
  node_instance_type = var.node_instance_type
  node_desired_size = var.node_desired_size
  node_max_size = var.node_max_size
  node_min_size = var.node_min_size
}

module "ecr" {
  source = "./modules/ecr"

  repository_name = "demo-service"
  tags = {
    Environment = "dev"
    Project     = "simple-eks"
  }
}