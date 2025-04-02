# Add IAM role for EKS cluster
resource "aws_iam_role" "cluster" {
  name = "${var.cluster-name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
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

resource "aws_iam_role_policy_attachment" "node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}

# Add Auto Scaling Group for worker nodes
resource "aws_autoscaling_group" "node" {
  name                = "${var.cluster-name}-asg"
  launch_template {
    id      = aws_launch_template.node.id
    version = "$Latest"
  }
  min_size            = var.node_min_size
  max_size            = var.node_max_size
  desired_capacity    = var.node_desired_size
  vpc_zone_identifier = var.subnet_ids

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster-name}"
    value               = "owned"
    propagate_at_launch = true
  }
}

# Add security group rules
resource "aws_security_group_rule" "cluster_to_node" {
  type                     = "ingress"
  from_port               = 10250
  to_port                 = 10250
  protocol                = "tcp"
  security_group_id       = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.node.id
}

resource "aws_security_group_rule" "node_to_node" {
  type                     = "ingress"
  from_port               = 0
  to_port                 = 65535
  protocol                = "-1"
  security_group_id       = aws_security_group.node.id
  source_security_group_id = aws_security_group.node.id
}

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

# Add AMI data source
data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.kubernetes_version}-v*"]
  }
  most_recent = true
  owners      = ["amazon"]
}

# Add IAM role for worker nodes
resource "aws_iam_role" "node" {
  name = "${var.cluster-name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
}

resource "aws_iam_instance_profile" "node" {
  name = "${var.cluster-name}-node-profile"
  role = aws_iam_role.node.name
}

# Update launch template
resource "aws_launch_template" "node" {
  name_prefix = "${var.cluster-name}-node-"
  
  instance_type = var.node_instance_type
  image_id      = data.aws_ami.eks-worker.id

  network_interfaces {
    associate_public_ip_address = true
    security_groups            = [aws_security_group.node.id]
    delete_on_termination      = true
  }

  iam_instance_profile {
    arn = aws_iam_instance_profile.node.arn
  }

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
