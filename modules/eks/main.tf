# Security Groups
resource "aws_security_group" "cluster" {
  name        = "${var.cluster-name}-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.cluster-name
  }
}

resource "aws_security_group" "node" {
  name        = "${var.cluster-name}-node"
  description = "Security group for all nodes in the cluster"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster-name}-node"
    "kubernetes.io/cluster/${var.cluster-name}" = "owned"
  }
}

# Rest of security group rules and other resources...

# EKS Cluster
resource "aws_eks_cluster" "demo" {
  name     = var.cluster-name
  version  = var.kubernetes_version
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    security_group_ids = [aws_security_group.cluster.id]
    subnet_ids         = var.subnet_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster-AmazonEKSServicePolicy,
  ]
}

# Worker Nodes
resource "aws_launch_template" "node" {
  name_prefix = "${var.cluster-name}-node"
  
  instance_type = var.node_instance_type
  image_id      = data.aws_ami.eks-worker.id

  vpc_security_group_ids = [aws_security_group.node.id]
  user_data = base64encode(templatefile("${path.module}/templates/userdata.sh", {
    cluster_name = aws_eks_cluster.demo.name
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.cluster-name}-node"
      "kubernetes.io/cluster/${var.cluster-name}" = "owned"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ... Rest of the resources
