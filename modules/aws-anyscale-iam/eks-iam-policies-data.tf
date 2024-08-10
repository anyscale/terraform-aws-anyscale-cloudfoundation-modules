#-----------------
# EKS Access
#-----------------
locals {
  create_eks_cluster_policies = var.create_anyscale_eks_cluster_role && var.module_enabled
  create_eks_node_policies    = var.create_anyscale_eks_node_role && var.module_enabled

  eks_cluster_assume_role_policy_body = templatefile("${path.module}/eks-cluster_assumerole.tmpl", {})
  eks_cluster_autoscaler_policy_body  = templatefile("${path.module}/eks-cluster_autoscaler.tmpl", {})

  eks_node_assume_role_policy_body = templatefile("${path.module}/eks-node_assumerole.tmpl", {})
}

# EKS Cluster Role
data "aws_iam_policy_document" "eks_cluster_assume_role" {
  count = local.create_eks_cluster_policies ? 1 : 0

  source_policy_documents = [local.eks_cluster_assume_role_policy_body]
}

data "aws_iam_policy_document" "eks_cluster_autoscaling_policy" {
  count = local.create_eks_cluster_policies ? 1 : 0

  source_policy_documents = [local.eks_cluster_autoscaler_policy_body]
}

# EKS Node Role
data "aws_iam_policy_document" "eks_node_assume_role" {
  count = local.create_eks_node_policies ? 1 : 0

  source_policy_documents = [local.eks_node_assume_role_policy_body]
}
