locals {
  module_enabled = var.module_enabled

  ng_base = {
    cluster_name  = var.eks_cluster_name
    node_role_arn = var.eks_node_role_arn
    subnet_ids    = sort(var.subnet_ids) # Keep sorted so that change in order does not trigger replacement
    version       = var.kubernetes_version

    force_update_version = var.force_update_version
    tags                 = merge(var.tags, local.module_tags)
  }

  module_tags = tomap({
    tf_sub_module = "aws-anyscale-eks-nodegroups"
  })
}


# ---------------------------------------------------------------------------------------------------------------------
# Management Node Group
# ---------------------------------------------------------------------------------------------------------------------
locals {
  ng_management = merge(local.ng_base, {
    instance_types = var.eks_management_instance_types
    labels         = var.eks_management_labels
    tags           = merge(var.eks_management_tags, local.ng_base.tags)
    capacity_type  = var.eks_management_capacity_type
    scaling_config = {
      desired_size = var.eks_manamgenet_desired_size
      max_size     = var.eks_management_max_size
      min_size     = var.eks_management_min_size
    }
  })
}
resource "aws_eks_node_group" "management" {
  count = local.module_enabled && var.create_eks_management_node_group ? 1 : 0

  node_group_name = var.eks_management_node_group_name

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  # From here to end of resource should be identical in both node groups
  cluster_name         = local.ng_management.cluster_name
  node_role_arn        = local.ng_management.node_role_arn
  subnet_ids           = local.ng_management.subnet_ids
  version              = local.ng_management.version
  force_update_version = local.ng_management.force_update_version

  instance_types = local.ng_management.instance_types
  capacity_type  = local.ng_management.capacity_type
  labels         = local.ng_management.labels
  tags           = local.ng_management.tags

  scaling_config {
    desired_size = local.ng_management.scaling_config.desired_size
    max_size     = local.ng_management.scaling_config.max_size
    min_size     = local.ng_management.scaling_config.min_size
  }

  dynamic "update_config" {
    for_each = length(var.eks_management_update_config) > 0 ? [var.eks_management_update_config] : []

    content {
      max_unavailable_percentage = try(update_config.value.max_unavailable_percentage, null)
      max_unavailable            = try(update_config.value.max_unavailable, null)
    }
  }

  dynamic "taint" {
    for_each = var.eks_management_taints
    content {
      key    = taint.value["key"]
      value  = taint.value["value"]
      effect = taint.value["effect"]
    }
  }

  dynamic "timeouts" {
    for_each = var.node_group_timeouts
    content {
      create = timeouts.value["create"]
      update = timeouts.value["update"]
      delete = timeouts.value["delete"]
    }
  }
}
