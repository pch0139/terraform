resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.name}_eks_cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [local.private_subnet_ids[0], local.private_subnet_ids[1]]
  }

  tags = {
    Name  = "${var.name}_eks_cluster"
    Owner = var.tag
  }
  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.pchoon-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.pchoon-AmazonEKSVPCResourceController,
  ]
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks_cluster_role" {
  name               = "${var.name}_eks_cluster_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags = {
    Name  = "${var.name}_eks_cluster_role"
    Owner = var.tag
  }
}

resource "aws_iam_role_policy_attachment" "pchoon-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "pchoon-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.name}_eks_node_group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = local.private_subnet_ids[*]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  tags = {
    Name  = "${var.name}_eks_node_group"
    Owner = var.tag
  }
  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.pchoon-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.pchoon-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.pchoon-AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.pchoon-AmazonSSMFullAccess,
    aws_iam_role.eks_node_role,
  ]
}

resource "aws_iam_role" "eks_node_role" {
  name = "${var.name}_eks_node_role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
    tags = {
    Name  = "${var.name}_eks_node_role"
    Owner = var.tag
  }
}

resource "aws_iam_role_policy_attachment" "pchoon-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "pchoon-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "pchoon-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "pchoon-AmazonSSMFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
  role       = aws_iam_role.eks_node_role.name
}