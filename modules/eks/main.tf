# AWS Academy: Usa LabRole já existente
resource "aws_eks_cluster" "main" {
    name = var.cluster_name
    role_arn = var.use_academy_role ? var.lab_role_arn : aws_iam_role.eks_cluster_role[0].arn

    vpc_config {
        subnet_ids = var.subnet_ids
        endpoint_private_access = true
        endpoint_public_access  = true
    }
}

resource "aws_eks_node_group" "main" {
    cluster_name = aws_eks_cluster.main.name
    node_group_name = "${var.cluster_name}-node-group"

    # Alterado de aws_iam_role.eks_node_group_role.arn para usar a LabRole do AWS Academy se use_academy_role for true
    node_role_arn = var.use_academy_role ? var.lab_role_arn : aws_iam_role.eks_node_role[0].arn
    subnet_ids = var.subnet_ids

    scaling_config {
        desired_size = 2
        max_size     = 3
        min_size     = 1
    }

    instance_types = ["t3.micro"]
}

# Fallback para ambiente AWS comum (Fora do Academy)
resource "aws_iam_role" "eks_cluster_role" {
    count = var.use_academy_role ? 0 : 1
    name = "${var.cluster_name}-eks-cluster-role"

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

resource "aws_iam_role" "eks_node_role" {
    count = var.use_academy_role ? 0 : 1
    name = "${var.cluster_name}-node-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            }
        ]
    })
}

# 1. VPC CNI
resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "vpc-cni"
  resolve_conflicts_on_create = "OVERWRITE"
}

# 2. CoreDNS
resource "aws_eks_addon" "coredns" {
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "coredns"
  resolve_conflicts_on_create = "OVERWRITE"

  depends_on = [aws_eks_node_group.main]
}

# 3. Kube-Proxy
resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "kube-proxy"
  resolve_conflicts_on_create = "OVERWRITE"
}
