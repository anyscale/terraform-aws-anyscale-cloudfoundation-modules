# ------------------------------
# EKS Cluster Outputs
# ------------------------------
output "eks_cluster_name" {
  description = "Name of the Anyscale EKS cluster"
  value       = try(aws_eks_cluster.anyscale_dataplane[0].name, "")
}
output "eks_cluster_id" {
  description = "ID of the Anyscale EKS cluster"
  value       = try(aws_eks_cluster.anyscale_dataplane[0].id, "")
}
output "eks_cluster_arn" {
  description = "ARN of the Anyscale EKS cluster"
  value       = try(aws_eks_cluster.anyscale_dataplane[0].arn, "")
}
output "eks_cluster_endpoint" {
  description = "Endpoint of the Anyscale EKS cluster"
  value       = try(aws_eks_cluster.anyscale_dataplane[0].endpoint, "")
}
output "eks_cluster_ca_data" {
  description = "Certificate Authority Data of the Anyscale EKS cluster"
  value       = try(aws_eks_cluster.anyscale_dataplane[0].certificate_authority[0].data, "")
}

output "eks_kubeconfig" {
  description = "Kubeconfig of the Anyscale EKS cluster"
  value = {
    endpoint               = try(aws_eks_cluster.anyscale_dataplane[0].endpoint, "")
    cluster_ca_certificate = try(aws_eks_cluster.anyscale_dataplane[0].certificate_authority[0].data, "")
  }
}
