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

# ... existing code ...

# Create a node IAM role for the worker nodes
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

# Attach essential EKS worker node policies
resource "aws_iam_role_policy_attachment" "node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
}

# Use an EKS-managed node group that references the existing launch template
resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.demo.name
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.subnet_ids
  launch_template {
    id      = aws_launch_template.node.id
    version = "$Latest"   # or a specific version number
  }

  # Example scaling configuration
  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  depends_on = [
    aws_iam_role.node,
    aws_eks_cluster.demo
  ]

  # Tag so EKS can auto-discover these nodes as part of the cluster
  tags = {
    Name = "${var.cluster-name}-node-group"
    "kubernetes.io/cluster/${var.cluster-name}" = "owned"
  }
}

# Add this provider block
provider "kubernetes" {
  host                   = aws_eks_cluster.demo.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.demo.certificate_authority[0].data)

  # Use aws cli to get token for authentication
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # Use the EKS cluster name to get the token
    args = ["eks", "get-token", "--cluster-name", aws_eks_cluster.demo.name]
  }
}

// variable "oidc_github_actions_role_arn" {
//   description = "The ARN of the IAM Role created for GitHub Actions OIDC."
//   type        = string
//   # You will provide this value via tfvars, env var, or secrets manager
// }

// variable "admin_user_arns" {
//   description = "A list of IAM User ARNs to grant cluster-admin access via system:masters."
//   type        = list(string)
//   default     = [] // Start with an empty list
//   # You will provide your user ARN here via tfvars, env var, etc.
// }

# Add this resource to manage the aws-auth ConfigMap
resource "kubernetes_config_map_v1" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
    # Add labels if desired
    # labels = {
    #   "managed-by" = "terraform"
    # }
  }

  # Ensure this runs after the cluster and node role are available
  depends_on = [
    aws_eks_cluster.demo,
    aws_iam_role.node # Important: Ensure node role ARN is ready
  ]

  data = {
    # --- Role Mappings ---
    mapRoles = yamlencode([
      # IMPORTANT: Worker Node Role Mapping - DO NOT REMOVE THIS
      # This allows your EC2 nodes to join the cluster
      {
        rolearn  = aws_iam_role.node.arn # Reference the node role created above
        username = "system:node:{{EC2PrivateDNSName}}"
        groups = [
          "system:bootstrappers",
          "system:nodes"
        ]
      },
      # GitHub Actions OIDC Role Mapping
      {
        rolearn  = var.oidc_github_actions_role_arn # Use the variable
        username = "github-actions:{{SessionName}}"
         # Assign to specific group(s) based on your RBAC setup,
         # or system:masters (with caution) if needed initially
        groups = [
           # "system:masters", # Example for admin access
           "cicd-runners"    # Example custom group
        ]
      },
      # Add any other roles you need mapped here
    ])

    # --- User Mappings ---
    mapUsers = yamlencode([
      # Map each user ARN provided in the variable list
      for user_arn in var.admin_user_arns : {
        userarn  = user_arn
        username = trimsuffix(split("/", user_arn)[1], "@*") # Extracts username, adjust if needed
        groups = [
          "system:masters" # WARNING: Grants full cluster admin. Use specific groups if possible.
        ]
      }
      # Add any other specific users you need mapped here
    ])

    # Add mapAccounts if you need to map entire AWS accounts
    # mapAccounts = yamlencode([
    #   "ACCOUNT_ID_1",
    #   "ACCOUNT_ID_2"
    # ])
  }

  # Use immutable = false if you expect to update this configmap often
  # immutable = false
}
