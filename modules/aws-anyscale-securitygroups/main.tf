locals {
  sg_name_prefix    = var.security_group_name != null ? null : coalesce(var.security_group_name_prefix, "anyscale-security-group-")
  security_group_id = try(aws_security_group.anyscale_security_group[0].id, var.existing_security_group_id, "")

  module_tags = tomap({
    tf_sub_module     = "aws-anyscale-securitygroups",
    anyscale_cloud_id = try(var.anyscale_cloud_id, "")
  })

  allow_all_egress = var.module_enabled && var.allow_all_egress
}

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
# Security Group Ingress Rules
# -----------------------------
# Security group rules with "cidr_blocks". This one is specific for Anyscale v1 stack
resource "aws_security_group_rule" "anyscale_public_ingress_rules" {
  count = var.module_enabled && var.create_anyscale_public_ingress ? length(var.anyscale_ingress_rules_v1) : 0

  security_group_id = local.security_group_id
  type              = "ingress"

  cidr_blocks = var.anyscale_public_ips_cidr
  description = var.predefined_rules[var.anyscale_ingress_rules_v1[count.index]][3]

  from_port = var.predefined_rules[var.anyscale_ingress_rules_v1[count.index]][0]
  to_port   = var.predefined_rules[var.anyscale_ingress_rules_v1[count.index]][1]
  protocol  = var.predefined_rules[var.anyscale_ingress_rules_v1[count.index]][2]

}

# Security group rules with "cidr_blocks"
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
    try(var.predefined_rules[lookup(var.ingress_from_cidr_map[count.index], "rule", "_")][0], ""),
  )
  to_port = lookup(
    var.ingress_from_cidr_map[count.index],
    "to_port",
    try(var.predefined_rules[lookup(var.ingress_from_cidr_map[count.index], "rule", "_")][1], ""),
  )
  protocol = lookup(
    var.ingress_from_cidr_map[count.index],
    "protocol",
    try(var.predefined_rules[lookup(var.ingress_from_cidr_map[count.index], "rule", "_")][2], ""),
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
    try(var.predefined_rules[lookup(var.ingress_with_self[count.index], "rule", "_")][0], ""),
  )
  to_port = lookup(
    var.ingress_with_self[count.index],
    "to_port",
    try(var.predefined_rules[lookup(var.ingress_with_self[count.index], "rule", "_")][1], ""),
  )
  protocol = lookup(
    var.ingress_with_self[count.index],
    "protocol",
    try(var.predefined_rules[lookup(var.ingress_with_self[count.index], "rule", "_")][2], ""),
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
    try(var.predefined_rules[lookup(var.ingress_with_existing_security_groups_map[count.index], "rule", "_")][0], ""),
  )
  to_port = lookup(
    var.ingress_with_existing_security_groups_map[count.index],
    "to_port",
    try(var.predefined_rules[lookup(var.ingress_with_existing_security_groups_map[count.index], "rule", "_")][1], ""),
  )
  protocol = lookup(
    var.ingress_with_existing_security_groups_map[count.index],
    "protocol",
    try(var.predefined_rules[lookup(var.ingress_with_existing_security_groups_map[count.index], "rule", "_")][2], ""),
  )
}

# -----------------------------
# Security Group Egress Rules
# -----------------------------
# Security group rule - ALL egress
#trivy:ignore:avd-aws-0104:Allow all egress traffic is a valid use case. Ignoring this alert.
resource "aws_security_group_rule" "egress_all_allowed" {
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
    try(var.predefined_rules[lookup(var.egress_to_cidr_map[count.index], "rule", "_")][0], ""),
  )
  to_port = lookup(
    var.egress_to_cidr_map[count.index],
    "to_port",
    try(var.predefined_rules[lookup(var.egress_to_cidr_map[count.index], "rule", "_")][1], ""),
  )
  protocol = lookup(
    var.egress_to_cidr_map[count.index],
    "protocol",
    try(var.predefined_rules[lookup(var.egress_to_cidr_map[count.index], "rule", "_")][2], ""),
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
    var.predefined_rules[lookup(var.egress_to_self[count.index], "rule", "_")][0],
  )
  to_port = lookup(
    var.egress_to_self[count.index],
    "to_port",
    var.predefined_rules[lookup(var.egress_to_self[count.index], "rule", "_")][1],
  )
  protocol = lookup(
    var.egress_to_self[count.index],
    "protocol",
    var.predefined_rules[lookup(var.egress_to_self[count.index], "rule", "_")][2],
  )
}
