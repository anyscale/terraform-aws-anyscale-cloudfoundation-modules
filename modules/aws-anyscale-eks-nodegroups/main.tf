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
resource "aws_eks_node_group" "management" {
  count = local.module_enabled && var.create_eks_management_node_group ? 1 : 0

  node_group_name = var.eks_management_node_group_config.name

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  # From here to end of resource should be identical in both node groups
  cluster_name         = local.ng_base.cluster_name
  node_role_arn        = local.ng_base.node_role_arn
  subnet_ids           = local.ng_base.subnet_ids
  version              = local.ng_base.version
  force_update_version = local.ng_base.force_update_version

  instance_types = var.eks_management_node_group_config.instance_types
  capacity_type  = var.eks_management_node_group_config.capacity_type
  labels         = var.eks_management_node_group_config.labels
  tags           = merge(var.eks_management_node_group_config.tags, local.ng_base.tags)

  scaling_config {
    desired_size = var.eks_management_node_group_config.scaling_config.desired_size
    max_size     = var.eks_management_node_group_config.scaling_config.max_size
    min_size     = var.eks_management_node_group_config.scaling_config.min_size
  }

  dynamic "update_config" {
    for_each = var.eks_management_node_group_config.update_config != null ? [var.eks_management_node_group_config.update_config] : []

    content {
      max_unavailable_percentage = try(update_config.value.max_unavailable_percentage, null)
      max_unavailable            = try(update_config.value.max_unavailable, null)
    }
  }

  dynamic "taint" {
    for_each = [
      for t in var.eks_management_node_group_config.taints :
      t if t.key != null && t.value != null && t.effect != null
    ]
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
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

# ---------------------------------------------------------------------------------------------------------------------
# Anyscale Node Groups
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_eks_node_group" "anyscale_node_groups" {
  for_each = local.module_enabled && var.create_anyscale_node_groups ? {
    for ng in var.eks_anyscale_node_groups :
    ng.name => ng
  } : {}

  node_group_name = each.value.name

  # From here to end of resource should be identical in both node groups
  cluster_name         = local.ng_base.cluster_name
  node_role_arn        = local.ng_base.node_role_arn
  subnet_ids           = local.ng_base.subnet_ids
  version              = local.ng_base.version
  force_update_version = local.ng_base.force_update_version

  instance_types = each.value.instance_types
  capacity_type  = each.value.capacity_type
  labels         = each.value.labels
  tags           = merge(each.value.tags, local.ng_base.tags)

  scaling_config {
    desired_size = each.value.scaling_config.desired_size
    max_size     = each.value.scaling_config.max_size
    min_size     = each.value.scaling_config.min_size
  }

  dynamic "update_config" {
    for_each = each.value.update_config != null ? [each.value.update_config] : []

    content {
      max_unavailable_percentage = try(update_config.value.max_unavailable_percentage, null)
      max_unavailable            = try(update_config.value.max_unavailable, null)
    }
  }

  dynamic "taint" {
    for_each = [
      for t in each.value.taints :
      t if t.key != null && t.value != null && t.effect != null
    ]
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
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

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}
