#
# EKS Worker Nodes Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
#  * EC2 Security Group to allow networking traffic
#  * Data source to fetch latest EKS worker AMI
#  * AutoScaling Launch Configuration to configure worker instances
#  * AutoScaling Group to launch worker instances
#

##############################
# IAM Roles and Instance Profiles
##############################

resource "aws_iam_role" "demo-node" {
  name = "terraform-eks-demo-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "demo-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.demo-node.name
}

resource "aws_iam_role_policy_attachment" "demo-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.demo-node.name
}

resource "aws_iam_role_policy_attachment" "demo-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.demo-node.name
}

resource "aws_iam_instance_profile" "demo-node" {
  name = "terraform-eks-demo"
  role = aws_iam_role.demo-node.name
}

resource "aws_iam_role" "breno-node" {
  name = "terraform-eks-breno-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "breno-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.breno-node.name
}

resource "aws_iam_role_policy_attachment" "breno-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.breno-node.name
}

resource "aws_iam_role_policy_attachment" "breno-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.breno-node.name
}

resource "aws_iam_instance_profile" "breno-node" {
  name = "terraform-eks-breno"
  role = aws_iam_role.breno-node.name
}

##############################
# Security Groups and Rules
##############################

resource "aws_security_group" "demo-node" {
  name        = "terraform-eks-demo-node"
  description = "Security group for all nodes in the cluster"
  vpc_id      = aws_vpc.demo.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                                      = "terraform-eks-demo-node"
    "kubernetes.io/cluster/${var.cluster-name}" = "owned"
  }
}

resource "aws_security_group_rule" "demo-node-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.demo-node.id
  source_security_group_id = aws_security_group.demo-node.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "demo-node-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.demo-node.id
  source_security_group_id = aws_security_group.demo-cluster.id
  to_port                  = 65535
  type                     = "ingress"
}

##############################
# Data Source for EKS Worker AMI
##############################

data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.demo.version}-v*"]
  }
  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

##############################
# Worker Node User Data
##############################

locals {
  demo-node-userdata = <<USERDATA
#!/bin/bash -xe
/etc/eks/bootstrap.sh ${aws_eks_cluster.demo.name}
USERDATA
}

##############################
# Launch Configurations
##############################

resource "aws_launch_configuration" "demo" {
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.demo-node.name
  image_id                    = data.aws_ami.eks-worker.id
  instance_type               = "m4.large"
  name_prefix                 = "terraform-eks-demo"
  security_groups             = [aws_security_group.demo-node.id]
  user_data_base64            = base64encode(local.demo-node-userdata)

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_eks_cluster.demo]
}

resource "aws_launch_configuration" "breno" {
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.breno-node.name
  image_id                    = data.aws_ami.eks-worker.id
  instance_type               = "m4.large"
  name_prefix                 = "terraform-eks-breno"
  security_groups             = [aws_security_group.demo-node.id]
  user_data_base64            = base64encode(local.demo-node-userdata)

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_eks_cluster.demo]
}

##############################
# AutoScaling Groups
##############################

resource "aws_autoscaling_group" "demo" {
  desired_capacity     = 2
  launch_configuration = aws_launch_configuration.demo.id
  max_size             = 2
  min_size             = 1
  name                 = "terraform-eks-demo"
  vpc_zone_identifier  = aws_subnet.demo[*].id

  tag {
    key                 = "Name"
    value               = "terraform-eks-demo"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster-name}"
    value               = "owned"
    propagate_at_launch = true
  }

  depends_on = [aws_launch_configuration.demo]
}

resource "aws_autoscaling_group" "breno" {
  desired_capacity     = 2
  launch_configuration = aws_launch_configuration.breno.id
  max_size             = 2
  min_size             = 1
  name                 = "terraform-eks-breno"
  vpc_zone_identifier  = aws_subnet.demo[*].id

  tag {
    key                 = "Name"
    value               = "terraform-eks-breno"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster-name}"
    value               = "owned"
    propagate_at_launch = true
  }

  depends_on = [aws_launch_configuration.breno]
}
