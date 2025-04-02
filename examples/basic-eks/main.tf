module "eks" {
  source = "../../modules/eks"
  
  aws_region = var.aws_region
  cluster_name = var.cluster_name
  availability_zones = var.availability_zones
  cluster_endpoint_allowed_cidrs = var.cluster_endpoint_allowed_cidrs
  map_admin_user_arn = var.map_admin_user_arn
}
