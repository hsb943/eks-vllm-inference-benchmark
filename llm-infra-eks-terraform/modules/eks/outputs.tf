output "cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_ca" {
  value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "cluster_token" {
  value = data.aws_eks_cluster_auth.eks.token
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.eks_oidc_provider.arn
}

output "oidc_provider_url" {
  value = aws_iam_openid_connect_provider.eks_oidc_provider.url
}
