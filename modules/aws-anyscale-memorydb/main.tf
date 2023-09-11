locals {
  memorydb_name        = try(var.anyscale_memorydb_name, null)
  memorydb_name_prefix = local.memorydb_name != null ? null : var.anyscale_memorydb_name_prefix != null ? var.anyscale_memorydb_name_prefix : "anyscale-mdb-"

  create_parameter_group = var.module_enabled && var.create_memorydb_parameter_group
  # memorydb_parameter_group_prefix = var.memorydb_parameter_group_name_prefix != null ? var.memorydb_parameter_group_name_prefix : "anyscale-mdb-pg-"
  memorydb_parameter_group_name = coalesce(var.memorydb_parameter_group_name, try(random_id.parameter_group_suffix[0].hex, null), "anyscale-mdb-pg-default")
  memorydb_parameter_group      = local.create_parameter_group ? aws_memorydb_parameter_group.anyscale_memorydb[0].id : var.existing_memorydb_parameter_group_name

  create_acl               = var.module_enabled && var.create_memorydb_acl
  memorydb_acl_name        = try(var.memorydb_acl_name, null)
  memorydb_acl_name_prefix = local.memorydb_acl_name != null ? null : var.memorydb_acl_name_prefix != null ? var.memorydb_acl_name_prefix : "anyscale-mdb-acl-"
  memorydb_acl             = local.create_acl ? aws_memorydb_acl.anyscale_memorydb[0].id : var.existing_memorydb_acl_name

  create_subnet_group          = var.module_enabled && var.create_memorydb_subnet_group
  memorydb_subnet_group_name   = try(var.memorydb_subnet_group_name, null)
  memorydb_subnet_group_prefix = local.memorydb_subnet_group_name != null ? null : var.memorydb_subnet_group_name_prefix != null ? var.memorydb_subnet_group_name_prefix : "anyscale-mdb-sg-"
  memorydb_subnet_group        = local.create_subnet_group ? aws_memorydb_subnet_group.anyscale_memorydb[0].id : var.existing_memorydb_subnet_group_name

  full_tags = merge(tomap({
    anyscale-cloud-id = var.anyscale_cloud_id
    }),
    var.tags
  )
}

#---------------------
# MemoryDB Cluster
#---------------------
resource "aws_memorydb_cluster" "anyscale_memorydb" {
  count = var.module_enabled ? 1 : 0

  name        = local.memorydb_name
  name_prefix = local.memorydb_name_prefix
  description = var.anyscale_memorydb_description

  engine_version             = var.memorydb_engine_version
  auto_minor_version_upgrade = var.enable_auto_minor_version_upgrade

  port                   = var.memorydb_port
  node_type              = var.memorydb_node_type
  num_shards             = var.memorydb_num_shards
  num_replicas_per_shard = var.memorydb_num_replicas_per_shard
  data_tiering           = var.enable_memorydb_data_tiering

  parameter_group_name = local.memorydb_parameter_group

  acl_name           = local.memorydb_acl
  kms_key_arn        = var.memorydb_kms_key_arn
  tls_enabled        = var.memorydb_tls_enabled
  security_group_ids = var.memorydb_security_group_ids
  subnet_group_name  = local.memorydb_subnet_group

  maintenance_window = var.memorydb_maintenance_window
  sns_topic_arn      = var.memorydb_sns_topic_arn

  snapshot_retention_limit = var.memorydb_snapshot_retention_limit
  snapshot_window          = var.memorydb_snapshot_window
  final_snapshot_name      = var.memorydb_final_snapshot_name

  tags = local.full_tags
}

#-------------------------
# MemoryDB Parameter Group
#-------------------------
resource "aws_memorydb_parameter_group" "anyscale_memorydb" {
  count = local.create_parameter_group ? 1 : 0

  name = local.memorydb_parameter_group_name
  # name_prefix = local.memorydb_parameter_group_prefix
  description = var.memorydb_parameter_group_description
  family      = var.memorydb_parameter_group_family

  dynamic "parameter" {
    for_each = var.memorydb_parameter_group_parameters
    content {
      name  = parameter.value.name
      value = tostring(parameter.value.value)
    }
  }

  # lifecycle {
  #   create_before_destroy = true
  # }

  tags = merge(local.full_tags, var.memorydb_parameter_group_tags)
}


#-------------------------
# MemoryDB ACL
#-------------------------
resource "aws_memorydb_acl" "anyscale_memorydb" {
  count = local.create_acl ? 1 : 0

  name        = local.memorydb_acl_name
  name_prefix = local.memorydb_acl_name_prefix

  user_names = distinct(concat([for u in aws_memorydb_user.anyscale_memorydb : u.id], var.memorydb_acl_user_names))

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.full_tags, var.memorydb_acl_tags)
}

#-------------------------
# MemoryDB Users
#-------------------------
resource "aws_memorydb_user" "anyscale_memorydb" {
  for_each = { for k, v in var.memorydb_users : k => v if var.module_enabled && var.create_memorydb_users }

  user_name     = each.value.user_name
  access_string = each.value.access_string

  authentication_mode {
    type      = "password"
    passwords = each.value.passwords
  }

  tags = merge(var.tags, lookup(each.value, "tags", {}))
}

#-------------------------
# MemoryDB Subnet Group
#-------------------------
resource "aws_memorydb_subnet_group" "anyscale_memorydb" {
  count = local.create_subnet_group ? 1 : 0

  name        = local.memorydb_subnet_group_name
  name_prefix = local.memorydb_subnet_group_prefix
  description = var.memorydb_subnet_group_description
  subnet_ids  = var.memorydb_subnet_ids

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.full_tags, var.memorydb_subnet_group_tags)
}

#-------------------------
# Supporting Resources
#-------------------------
locals {
  create_random_pg_suffix = var.module_enabled ? 1 : 0
}
resource "random_id" "parameter_group_suffix" {
  count = local.create_random_pg_suffix

  byte_length = 16
  prefix      = var.memorydb_parameter_group_name_prefix
}
