locals {
  module_enabled = var.module_enabled && var.anyscale_subnet_count > 0

  eks_cluster_encryption_config_enabled = var.eks_cluster_encryption_config_kms_key_arn != null ? true : false

  eks_name_cloud_id = var.anyscale_cloud_id != null && var.anyscale_eks_name == null ? "eks-${var.anyscale_cloud_id}" : null
  eks_name          = coalesce(var.anyscale_eks_name, local.eks_name_cloud_id, "eks-anyscale")

  module_tags = tomap({
    tf_sub_module = "aws-anyscale-eks"
  })
}

#trivy:ignore:AVD-AWS-0038:Logging is decided by the user
#trivy:ignore:avd-aws-0039:Encryption is decided by the user
#trivy:ignore:avd-aws-0040:Public access is decided by the user
#trivy:ignore:avd-aws-0041:CIDR range is decided by the user
resource "aws_eks_cluster" "anyscale_dataplane" {
  #checkov:skip=CKV_AWS_37:Control plane logging is decided by the user
  #checkov:skip=CKV_AWS_38:CIDR Range is decided by the user
  #checkov:skip=CKV_AWS_58:Encryption is decided by the user
  #checkov:skip=CKV_AWS_39:Public access is decided by the user
  count = local.module_enabled ? 1 : 0
  name  = local.eks_name

  role_arn                  = var.eks_role_arn
  version                   = var.kubernetes_version
  enabled_cluster_log_types = var.enabled_cluster_log_types

  vpc_config {
    security_group_ids      = compact(distinct(concat(var.additional_security_group_ids, [var.anyscale_security_group_id])))
    subnet_ids              = coalescelist(var.anyscale_subnet_ids)
    endpoint_private_access = var.eks_endpoint_private_access
    endpoint_public_access  = var.eks_endpoint_public_access
    public_access_cidrs     = var.eks_endpoint_public_access_cidrs
  }

  dynamic "encryption_config" {
    for_each = local.eks_cluster_encryption_config_enabled ? [1] : []
    content {
      resources = var.eks_cluster_encryption_config_resources
      provider {
        key_arn = var.eks_cluster_encryption_config_kms_key_arn
      }
    }
  }

  tags = merge(
    local.module_tags,
    var.tags,
  )
}