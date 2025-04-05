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
        from_port                = 443
        protocol                 = "tcp"
        security_group_id        = aws_security_group.cluster.id
        source_security_group_id = aws_security_group.node.id
        to_port                  = 443
        type                     = "ingress"
    }

    resource "aws_security_group_rule" "node-ingress-self" {
        description              = "Allow node to communicate with each other"
        from_port                = 0
        protocol                 = "-1"
        security_group_id        = aws_security_group.node.id
        source_security_group_id = aws_security_group.node.id
        to_port                  = 65535
        type                     = "ingress"
    }

    resource "aws_security_group_rule" "node-ingress-cluster" {
        description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
        from_port                = 1025
        protocol                 = "tcp"
        security_group_id        = aws_security_group.node.id
        source_security_group_id = aws_security_group.cluster.id
        to_port                  = 65535
        type                     = "ingress"
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
        name_prefix   = "${var.cluster-name}-launch-template"
        instance_type = var.node_instance_type
        image_id      = data.aws_ami.eks-worker.id

        tag_specifications {
            resource_type = "instance"
            tags = {
                Name = "${var.cluster-name}-node"
                "kubernetes.io/cluster/${var.cluster-name}" = "owned"
            }
        }
        tags = {
            Name = "${var.cluster-name}-launch-template"
        }
    }

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
        node_group_name = "${var.cluster-name}-node-group"
        node_role_arn   = aws_iam_role.node.arn
        subnet_ids      = var.subnet_ids
        launch_template {
            name    = aws_launch_template.node.name         # ADDED name reference
            version = aws_launch_template.node.latest_version
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
            # This section remains unchanged
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
            ]), # Closing parenthesis for mapRoles yamlencode

            # --- User Mappings (Revised for single user) ---
            mapUsers = yamlencode(
                # Condition: Only proceed if BOTH the admin ARN string AND the admin username string are not empty
                (var.admin_user_arns != "" && var.admin_k8s_username != "") ?
                # If TRUE: Create a list containing one user map object
                [
                    {
                        userarn  = var.admin_user_arns      # Use the admin ARN string directly
                        username = var.admin_k8s_username   # Use the admin username string directly
                        groups   = [ "system:masters" ]     # Grant admin privileges
                    }
                ] :
                # If FALSE (either variable is empty): Create an empty list
                []
            ) # Closing parenthesis for mapUsers yamlencode

        } # Closing brace for the data block
    }

    resource "aws_iam_instance_profile" "node" {
        name = "${var.cluster-name}-node-profile"
        role = aws_iam_role.node.name
    }