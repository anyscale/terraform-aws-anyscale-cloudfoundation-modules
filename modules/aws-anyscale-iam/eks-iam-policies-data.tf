#-----------------
# EKS Access
#-----------------
locals {
  create_eks_cluster_policies = var.create_anyscale_eks_cluster_role && var.module_enabled
  create_eks_node_policies    = var.create_anyscale_eks_node_role && var.module_enabled

  eks_cluster_assume_role_policy_body = templatefile("${path.module}/eks-cluster_assumerole.tmpl", {})

  eks_node_assume_role_policy_body = templatefile("${path.module}/eks-node_assumerole.tmpl", {})
  eks_node_autoscaler_policy_body = templatefile("${path.module}/eks-node_autoscaler.tmpl", {
    anyscale_eks_cluster_name = coalesce(var.anyscale_eks_cluster_name, "empty")
  })

  eks_ebs_csi_assume_role_policy_body = templatefile("${path.module}/eks-ebs-csi-assumerole.tmpl",
    {
      anyscale_eks_cluster_oidc_arn      = coalesce(var.anyscale_eks_cluster_oidc_arn, "empty"),
      anyscale_eks_cluster_oidc_provider = try(replace(var.anyscale_eks_cluster_oidc_url, "https://", ""), "empty")
    }
  )

  eks_efs_csi_assume_role_policy_body = templatefile("${path.module}/eks-efs-csi-assumerole.tmpl",
    {
      anyscale_eks_cluster_oidc_arn      = coalesce(var.anyscale_eks_cluster_oidc_arn, "empty"),
      anyscale_eks_cluster_oidc_provider = try(replace(var.anyscale_eks_cluster_oidc_url, "https://", ""), "empty")
    }
  )
}

# EKS Cluster Role
data "aws_iam_policy_document" "eks_cluster_assume_role" {
  count = local.create_eks_cluster_policies ? 1 : 0

  source_policy_documents = [local.eks_cluster_assume_role_policy_body]
}

# EKS Node Role
data "aws_iam_policy_document" "eks_node_assume_role" {
  count = local.create_eks_node_policies ? 1 : 0

  source_policy_documents = [local.eks_node_assume_role_policy_body]
}
data "aws_iam_policy_document" "eks_node_autoscaling_policy" {
  count = local.create_eks_cluster_policies ? 1 : 0

  source_policy_documents = [local.eks_node_autoscaler_policy_body]
}

# EKS EBS CSI Driver Policy
data "aws_iam_policy_document" "eks_ebs_csi_driver_assume_role" {
  count = local.create_ebs_csi_driver_role ? 1 : 0

  source_policy_documents = [local.eks_ebs_csi_assume_role_policy_body]
}

# EKS EFS CSI Driver Policy
data "aws_iam_policy_document" "eks_efs_csi_driver_assume_role" {
  count = local.create_efs_csi_driver_role ? 1 : 0

  source_policy_documents = [local.eks_efs_csi_assume_role_policy_body]
}
