output "cluster_id" {
  description = "Nome/ID do cluster EKS"
  value       = aws_eks_cluster.main.id
}

output "cluster_endpoint" {
  description = "Endpoint do API Server do EKS"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_security_group_id" {
  description = "ID do Security Group atribuído ao cluster EKS"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}