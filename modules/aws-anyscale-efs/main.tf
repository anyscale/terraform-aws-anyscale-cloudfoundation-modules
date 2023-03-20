locals {
  efs_name_cloud_id = var.anyscale_cloud_id != null && var.anyscale_efs_name == null ? "efs-${var.anyscale_cloud_id}" : null
  efs_name          = coalesce(var.anyscale_efs_name, local.efs_name_cloud_id, "efs-anyscale")

  module_tags = tomap({
    tf_sub_module = "aws-anyscale-efs"
  })
}


resource "aws_efs_file_system" "anyscale_efs" {
  count = var.module_enabled ? 1 : 0

  availability_zone_name          = var.availability_zone_name
  creation_token                  = var.efs_creation_token
  performance_mode                = var.efs_performance_mode
  encrypted                       = var.efs_encrypted
  kms_key_id                      = var.kms_key_arn
  provisioned_throughput_in_mibps = var.provisioned_throughput_in_mibps
  throughput_mode                 = var.efs_throughput_mode

  dynamic "lifecycle_policy" {
    for_each = length(var.lifecycle_policy_transition_to_ia) > 0 ? [1] : []
    content {
      transition_to_ia = try(var.lifecycle_policy_transition_to_ia[0], null)
    }
  }

  dynamic "lifecycle_policy" {
    for_each = length(var.lifecycle_policy_transition_to_primary_storage_class) > 0 ? [1] : []
    content {
      transition_to_primary_storage_class = try(var.lifecycle_policy_transition_to_primary_storage_class[0], null)
    }
  }

  tags = merge(
    { Name = local.efs_name },
    local.module_tags,
    var.tags,
  )
}

# ------------------
# EFS Backup Policy
# ------------------
resource "aws_efs_backup_policy" "anyscale_efs" {
  count = var.module_enabled && var.create_backup_policy ? 1 : 0

  file_system_id = aws_efs_file_system.anyscale_efs[0].id

  backup_policy {
    status = var.enable_backup_policy ? "ENABLED" : "DISABLED"
  }
}

# -----------------
# EFS Mount Target
# -----------------
resource "aws_efs_mount_target" "anyscale_efs" {
  count = var.module_enabled && var.mount_targets_subnet_count > 0 ? var.mount_targets_subnet_count : 0

  file_system_id  = aws_efs_file_system.anyscale_efs[0].id
  ip_address      = try(var.mount_target_ips[count.index], null)
  subnet_id       = var.mount_targets_subnets[count.index]
  security_groups = var.associated_security_group_ids
}

# -----------
# EFS Policy
# -----------
data "aws_iam_policy_document" "policy" {
  count = var.module_enabled && var.attach_policy ? 1 : 0

  source_policy_documents   = var.source_policy_documents
  override_policy_documents = var.override_policy_documents

  dynamic "statement" {
    for_each = var.policy_statements

    content {
      sid           = try(statement.value.sid, null)
      actions       = try(statement.value.actions, null)
      not_actions   = try(statement.value.not_actions, null)
      effect        = try(statement.value.effect, null)
      resources     = try(statement.value.resources, [aws_efs_file_system.anyscale_efs[0].arn], null)
      not_resources = try(statement.value.not_resources, null)

      dynamic "principals" {
        for_each = try(statement.value.principals, [])

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = try(statement.value.not_principals, [])

        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = try(statement.value.conditions, [])

        content {
          test     = condition.value.test
          values   = condition.value.values
          variable = condition.value.variable
        }
      }
    }
  }

  statement {
    sid    = "NonSecureTransport"
    effect = "Allow"
    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite"
    ]
    resources = [aws_efs_file_system.anyscale_efs[0].arn]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["true"]
    }
  }
}

resource "aws_efs_file_system_policy" "anyscale_efs" {
  count = var.module_enabled && var.attach_policy ? 1 : 0

  file_system_id                     = aws_efs_file_system.anyscale_efs[0].id
  bypass_policy_lockout_safety_check = var.bypass_policy_lockout_safety_check
  policy                             = data.aws_iam_policy_document.policy[0].json
}

# ----------------
# Access Point(s)
# ----------------
resource "aws_efs_access_point" "anyscale_efs" {
  for_each = { for k, v in var.access_points : k => v if var.module_enabled }

  file_system_id = aws_efs_file_system.anyscale_efs[0].id

  dynamic "posix_user" {
    for_each = try([each.value.posix_user], [])

    content {
      gid            = posix_user.value.gid
      uid            = posix_user.value.uid
      secondary_gids = try(posix_user.value.secondary_gids, null)
    }
  }

  dynamic "root_directory" {
    for_each = try([each.value.root_directory], [])

    content {
      path = try(root_directory.value.path, null)

      dynamic "creation_info" {
        for_each = try([root_directory.value.creation_info], [])

        content {
          owner_gid   = creation_info.value.owner_gid
          owner_uid   = creation_info.value.owner_uid
          permissions = creation_info.value.permissions
        }
      }
    }
  }

  tags = merge(
    var.tags,
    local.module_tags,
    try(each.value.tags, {}),
    { Name = try(each.value.name, each.key) },
  )
}

# --------------------------
# Replication Configuration
# --------------------------
resource "aws_efs_replication_configuration" "anyscale_efs" {
  count = var.module_enabled && var.create_replication_configuration ? 1 : 0

  source_file_system_id = aws_efs_file_system.anyscale_efs[0].id

  dynamic "destination" {
    for_each = [var.replication_configuration_destination]

    content {
      availability_zone_name = try(destination.value.availability_zone_name, null)
      kms_key_id             = try(destination.value.kms_key_id, null)
      region                 = try(destination.value.region, null)
    }
  }
}
