locals {
  sg_name_prefix              = var.security_group_name != null ? null : coalesce(var.security_group_name_prefix, "anyscale-security-group-")
  machine_pool_sg_name_prefix = var.machine_pool_security_group_name != null ? null : coalesce(var.machine_pool_security_group_name_prefix, "anyscale-machine-pool-sg-")
  security_group_id           = try(aws_security_group.anyscale_security_group[0].id, var.existing_security_group_id, "")

  module_tags = tomap({
    tf_sub_module     = "aws-anyscale-securitygroups",
    anyscale_cloud_id = try(var.anyscale_cloud_id, "")
  })

  allow_all_egress = var.module_enabled && var.allow_all_egress
}

# -----------------------------
# Default Anyscale Security Group
# -----------------------------
resource "aws_security_group" "anyscale_security_group" {
  #checkov:skip=CKV2_AWS_5:This is a Security Group Module and the security groups will not be attached to a resource in this module.
  count = var.module_enabled && var.create_security_group ? 1 : 0

  name        = try(var.security_group_name, null)
  name_prefix = local.sg_name_prefix
  description = var.security_group_description
  vpc_id      = var.vpc_id

  revoke_rules_on_delete = var.revoke_rules_on_delete

  timeouts {
    create = var.security_group_create_timeout
    delete = var.security_group_delete_timeout
  }

  tags = merge(
    { "Name" = coalesce(var.security_group_name, "anyscale-security-group") },
    local.module_tags,
    var.tags
  )
}


# -----------------------------
# Default Anyscale Security Group Ingress Rules
# -----------------------------
# Commenting out - this was for Anyscale v1 stack which is no longer supported.
# resource "aws_security_group_rule" "anyscale_public_ingress_rules" {
#   count = var.module_enabled && var.create_anyscale_public_ingress ? length(var.anyscale_ingress_rules_v1) : 0

#   security_group_id = local.security_group_id
#   type              = "ingress"

#   cidr_blocks = var.anyscale_public_ips_cidr
#   description = var.predefined_rules[var.anyscale_ingress_rules_v1[count.index]].description

#   from_port = var.predefined_rules[var.anyscale_ingress_rules_v1[count.index]].from_port
#   to_port   = var.predefined_rules[var.anyscale_ingress_rules_v1[count.index]].to_port
#   protocol  = var.predefined_rules[var.anyscale_ingress_rules_v1[count.index]].protocol
# }

# Security group rules with "cidr_blocks"
#trivy:ignore:avd-aws-0124
resource "aws_security_group_rule" "ingress_from_cidr_blocks" {
  count = var.module_enabled ? length(var.ingress_from_cidr_map) : 0

  security_group_id = local.security_group_id
  type              = "ingress"

  cidr_blocks = split(
    ",",
    lookup(
      var.ingress_from_cidr_map[count.index],
      "cidr_blocks",
      join(",", var.default_ingress_cidr_range),
    ),
  )

  description = lookup(
    var.ingress_from_cidr_map[count.index],
    "description",
    "Ingress Rule",
  )

  from_port = lookup(
    var.ingress_from_cidr_map[count.index],
    "from_port",
    try(var.predefined_rules[lookup(var.ingress_from_cidr_map[count.index], "rule", "_")].from_port, ""),
  )
  to_port = lookup(
    var.ingress_from_cidr_map[count.index],
    "to_port",
    try(var.predefined_rules[lookup(var.ingress_from_cidr_map[count.index], "rule", "_")].to_port, ""),
  )
  protocol = lookup(
    var.ingress_from_cidr_map[count.index],
    "protocol",
    try(var.predefined_rules[lookup(var.ingress_from_cidr_map[count.index], "rule", "_")].protocol, ""),
  )
}

# Security group rules with "self"
resource "aws_security_group_rule" "ingress_with_self" {
  count = var.module_enabled ? length(var.ingress_with_self) : 0

  security_group_id = local.security_group_id
  type              = "ingress"

  self = lookup(var.ingress_with_self[count.index], "self", true)

  description = lookup(
    var.ingress_with_self[count.index],
    "description",
    "Ingress Rule",
  )

  from_port = lookup(
    var.ingress_with_self[count.index],
    "from_port",
    try(var.predefined_rules[lookup(var.ingress_with_self[count.index], "rule", "_")].from_port, ""),
  )
  to_port = lookup(
    var.ingress_with_self[count.index],
    "to_port",
    try(var.predefined_rules[lookup(var.ingress_with_self[count.index], "rule", "_")].to_port, ""),
  )
  protocol = lookup(
    var.ingress_with_self[count.index],
    "protocol",
    try(var.predefined_rules[lookup(var.ingress_with_self[count.index], "rule", "_")].protocol, ""),
  )
}

# Security group rules with existing security groups
resource "aws_security_group_rule" "ingress_with_existing_security_groups" {
  count = var.module_enabled ? length(var.ingress_with_existing_security_groups_map) : 0

  security_group_id = local.security_group_id
  type              = "ingress"

  source_security_group_id = lookup(
    var.ingress_with_existing_security_groups_map[count.index],
    "security_group_id",
    ",",
  )


  description = lookup(
    var.ingress_with_existing_security_groups_map[count.index],
    "description",
    "Ingress Rule",
  )

  from_port = lookup(
    var.ingress_with_existing_security_groups_map[count.index],
    "from_port",
    try(var.predefined_rules[lookup(var.ingress_with_existing_security_groups_map[count.index], "rule", "_")].from_port, ""),
  )
  to_port = lookup(
    var.ingress_with_existing_security_groups_map[count.index],
    "to_port",
    try(var.predefined_rules[lookup(var.ingress_with_existing_security_groups_map[count.index], "rule", "_")].to_port, ""),
  )
  protocol = lookup(
    var.ingress_with_existing_security_groups_map[count.index],
    "protocol",
    try(var.predefined_rules[lookup(var.ingress_with_existing_security_groups_map[count.index], "rule", "_")].protocol, ""),
  )
}

# -----------------------------
# Security Group Egress Rules
# -----------------------------
# Security group rule - ALL egress
#trivy:ignore:avd-aws-0104:Egress is required to the internet for the Anyscale Control Plane and other services.
resource "aws_security_group_rule" "egress_all_allowed" {
  #checkov:skip=CKV_AWS_382:Egress is required to the internet for the Anyscale Control Plane and other services.
  count = local.allow_all_egress ? 1 : 0

  security_group_id = local.security_group_id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Egress all to all"
  from_port         = "-1"
  to_port           = "-1"
  protocol          = "-1"
}

# Security group rules to "cidr_blocks"
resource "aws_security_group_rule" "egress_to_cidr_blocks" {
  count = var.module_enabled ? length(var.egress_to_cidr_map) : 0

  security_group_id = local.security_group_id
  type              = "egress"

  cidr_blocks = split(
    ",",
    lookup(
      var.egress_to_cidr_map[count.index],
      "cidr_blocks",
      join(",", var.default_egress_cidr_range),
    ),
  )

  description = lookup(
    var.egress_to_cidr_map[count.index],
    "description",
    "Egress Rule",
  )

  from_port = lookup(
    var.egress_to_cidr_map[count.index],
    "from_port",
    try(var.predefined_rules[lookup(var.egress_to_cidr_map[count.index], "rule", "_")].from_port, ""),
  )
  to_port = lookup(
    var.egress_to_cidr_map[count.index],
    "to_port",
    try(var.predefined_rules[lookup(var.egress_to_cidr_map[count.index], "rule", "_")].to_port, ""),
  )
  protocol = lookup(
    var.egress_to_cidr_map[count.index],
    "protocol",
    try(var.predefined_rules[lookup(var.egress_to_cidr_map[count.index], "rule", "_")].protocol, ""),
  )
}

# Security group rules to "self"
resource "aws_security_group_rule" "egress_to_self" {
  count = var.module_enabled ? length(var.egress_to_self) : 0

  security_group_id = local.security_group_id
  type              = "egress"

  self = lookup(var.egress_to_self[count.index], "self", true)
  # prefix_list_ids = var.egress_prefix_list_ids
  description = lookup(
    var.egress_to_self[count.index],
    "description",
    "Egress Rule",
  )

  from_port = lookup(
    var.egress_to_self[count.index],
    "from_port",
    var.predefined_rules[lookup(var.egress_to_self[count.index], "rule", "_")].from_port,
  )
  to_port = lookup(
    var.egress_to_self[count.index],
    "to_port",
    var.predefined_rules[lookup(var.egress_to_self[count.index], "rule", "_")].to_port,
  )
  protocol = lookup(
    var.egress_to_self[count.index],
    "protocol",
    var.predefined_rules[lookup(var.egress_to_self[count.index], "rule", "_")].protocol,
  )
}

# -----------------------------
# Machine Pool Security Group
# -----------------------------
# Create a separate security group for machine pools
resource "aws_security_group" "machine_pool" {
  #checkov:skip=CKV2_AWS_5:This is a Security Group Module and the security groups will not be attached to a resource in this module.
  count = var.module_enabled && length(var.machine_pool_cidr_ranges) > 0 ? 1 : 0

  name_prefix = var.machine_pool_security_group_name == null ? local.machine_pool_sg_name_prefix : null
  name        = try(var.machine_pool_security_group_name, null)

  description = var.machine_pool_security_group_description
  vpc_id      = var.vpc_id

  revoke_rules_on_delete = var.revoke_rules_on_delete

  tags = merge(
    { "Name" = coalesce(var.machine_pool_security_group_name, "anyscale-machinepool-security-group") },
    local.module_tags,
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Machine pool ports ingress rules
resource "aws_security_group_rule" "machine_pool_ports_ingress" {
  count = var.module_enabled && length(var.machine_pool_cidr_ranges) > 0 ? length(var.machine_pool_port_ranges) * length(var.machine_pool_cidr_ranges) : 0

  security_group_id = aws_security_group.machine_pool[0].id
  type              = "ingress"
  cidr_blocks       = [var.machine_pool_cidr_ranges[floor(count.index / length(var.machine_pool_port_ranges))]]

  description = var.machine_pool_port_ranges[count.index % length(var.machine_pool_port_ranges)].description
  from_port   = var.machine_pool_port_ranges[count.index % length(var.machine_pool_port_ranges)].from_port
  to_port     = var.machine_pool_port_ranges[count.index % length(var.machine_pool_port_ranges)].to_port
  protocol    = "tcp"
}

# Allow all egress from machine pool security group
#trivy:ignore:AVD-AWS-0104:Egress is required to the internet for the Anyscale Control Plane and other services.
resource "aws_security_group_rule" "machine_pool_egress_all" {
  #checkov:skip=CKV_AWS_382:Egress is required to the internet for the Anyscale Control Plane and other services.
  count = var.module_enabled && length(var.machine_pool_cidr_ranges) > 0 ? 1 : 0

  security_group_id = aws_security_group.machine_pool[0].id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all egress from machine pool"
  from_port         = -1
  to_port           = -1
  protocol          = "-1"
}

# -----------------------------
# Main Security Group - Machine Pool Reference
# -----------------------------
# Allow ingress from machine pool security group to main security group
resource "aws_security_group_rule" "main_from_machine_pool" {
  count = var.module_enabled && length(var.machine_pool_cidr_ranges) > 0 ? 1 : 0

  security_group_id        = local.security_group_id
  type                     = "ingress"
  source_security_group_id = aws_security_group.machine_pool[0].id

  description = "Allow all traffic from machine pool security group"
  from_port   = -1
  to_port     = -1
  protocol    = "-1"
}
