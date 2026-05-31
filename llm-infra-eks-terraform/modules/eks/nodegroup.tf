resource "aws_iam_role" "eks_node_role" {
  name = "${var.name_prefix}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "node_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ])

  role       = aws_iam_role.eks_node_role.name
  policy_arn = each.value
}



resource "aws_eks_node_group" "cpu_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "cpu-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 3
  }

  instance_types = ["t3.medium"]

  labels = {
    workload-type = "cpu"
  }
}

resource "aws_eks_node_group" "gpu_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "gpu-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.private_subnet_ids

  ami_type      = "AL2023_x86_64_NVIDIA"
  capacity_type = "ON_DEMAND"
  disk_size     = 100

  scaling_config {
    desired_size = 1
    min_size     = 0
    max_size     = 1
  }

  instance_types = ["g5.2xlarge"]

  labels = {
    workload-type = "gpu"
  }

  taint {
    key    = "nvidia.com/gpu"
    effect = "NO_SCHEDULE"
  }
}
