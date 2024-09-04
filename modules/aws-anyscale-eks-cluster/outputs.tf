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

output "eks_cluster_oidc_provider_arn" {
  description = "OIDC provider of the Anyscale EKS cluster"
  value       = try(aws_iam_openid_connect_provider.anyscale_dataplane[0].arn, "")
}

output "eks_cluster_oidc_provider_url" {
  description = "OIDC provider URL of the Anyscale EKS cluster"
  value       = try(aws_iam_openid_connect_provider.anyscale_dataplane[0].url, "")
}

output "eks_kubeconfig" {
  description = "Kubeconfig of the Anyscale EKS cluster"
  value = {
    endpoint               = try(aws_eks_cluster.anyscale_dataplane[0].endpoint, "")
    cluster_ca_certificate = try(aws_eks_cluster.anyscale_dataplane[0].certificate_authority[0].data, "")
  }
}

output "cluster_managed_security_group_id" {
  description = <<-EOT
    Security Group ID that was created by EKS for the cluster.
    EKS creates a Security Group and applies it to the ENI that are attached to EKS Control Plane master nodes and to any managed workloads.
    EOT
  value       = one(aws_eks_cluster.anyscale_dataplane[*].vpc_config[0].cluster_security_group_id)
}
