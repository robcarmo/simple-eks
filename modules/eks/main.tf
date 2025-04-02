





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

# Add security group rules for cluster-node communication
resource "aws_security_group_rule" "cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port               = 443
  protocol                = "tcp"
  security_group_id       = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.node.id
  to_port                 = 443
  type                    = "ingress"
}

resource "aws_security_group_rule" "node-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port               = 0
  protocol                = "-1"
  security_group_id       = aws_security_group.node.id
  source_security_group_id = aws_security_group.node.id
  to_port                 = 65535
  type                    = "ingress"
}

resource "aws_security_group_rule" "node-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port               = 1025
  protocol                = "tcp"
  security_group_id       = aws_security_group.node.id
  source_security_group_id = aws_security_group.cluster.id
  to_port                 = 65535
  type                    = "ingress"
}

# Add IAM role for EKS cluster
resource "aws_iam_role" "cluster" {
  name = "${var.cluster-name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.cluster.name
}

# EKS Cluster
resource "aws_eks_cluster" "demo" {
  name     = var.cluster-name
  version  = var.kubernetes_version
  role_arn = aws_iam_role.cluster.arn  # Correct reference to the new cluster role

  vpc_config {
    security_group_ids = [aws_security_group.cluster.id]
    subnet_ids         = var.subnet_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster-AmazonEKSClusterPolicy,  # Now exists
    aws_iam_role_policy_attachment.cluster-AmazonEKSServicePolicy,  # Now exists
  ]
}

# Add AMI data source
data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.kubernetes_version}-v*"]
  }
  most_recent = true
  owners      = ["amazon"]
}

# Worker node configuration
resource "aws_launch_template" "node" {
  name_prefix = "${var.cluster-name}-node-"
  instance_type = var.node_instance_type
  image_id      = data.aws_ami.eks-worker.id

  user_data = base64encode(templatefile("${path.module}/templates/userdata.sh", {
    CLUSTER_NAME = aws_eks_cluster.demo.name
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.cluster-name}-node"
      "kubernetes.io/cluster/${var.cluster-name}" = "owned"
    }
  }
}
