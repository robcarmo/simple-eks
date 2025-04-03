module "eks" {
  source = "./modules/eks"
  cluster-name = var.cluster-name
  kubernetes_version = var.kubernetes_version
  vpc_id = module.vpc.vpc_id
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
