locals {
  vpc_name_cloud_id = var.anyscale_vpc_name == null && var.anyscale_cloud_id != null ? "vpc-${var.anyscale_cloud_id}" : null
  vpc_name          = coalesce(var.anyscale_vpc_name, local.vpc_name_cloud_id, "vpc-anyscale")

  # Use `local.vpc_id` to let Terraform know that subnets should be deleted before secondary CIDR blocks can be released.
  new_vpc_id = try(aws_vpc_ipv4_cidr_block_association.anyscale_vpc[0].vpc_id, aws_vpc.anyscale_vpc[0].id, "")
  vpc_id     = var.existing_vpc_id == null ? local.new_vpc_id : var.existing_vpc_id
  create_vpc = var.existing_vpc_id == null && var.module_enabled ? true : false

  # --------------------------------------------------------------------
  # Determine the set of availability zones in which to deploy subnets
  # Priority is
  # - availability_zone_ids
  # - availability_zones
  # - data.aws_availability_zones.default
  max_az_count = max(var.max_az_count, length(var.availability_zone_ids), length(var.availability_zones), length(var.public_subnets), length(var.private_subnets), 0)

  use_az_ids = var.module_enabled && length(var.availability_zone_ids) > 0
  use_az_var = var.module_enabled && length(var.availability_zones) > 0
  # use_default_azs = var.module_enabled && !(local.use_az_ids || local.use_az_var)

  # Create a map of AZ IDs to AZ names (and the reverse),
  # but fail safely, because AZ IDs are not always available.
  az_id_map = try(zipmap(data.aws_availability_zones.default[0].zone_ids, data.aws_availability_zones.default[0].names), {})
  # az_name_map = try(zipmap(data.aws_availability_zones.default[0].names, data.aws_availability_zones.default[0].zone_ids), {})

  # Create a map of options, not necessarily all filled in, to separate creating the option
  # from selecting the option, making the code easier to understand.
  az_option_map = {
    from_az_ids = var.module_enabled ? [for id in var.availability_zone_ids : local.az_id_map[id]] : []
    from_az_var = var.module_enabled ? var.availability_zones : []
    all_azs     = var.module_enabled ? sort(data.aws_availability_zones.default[0].names) : []
  }

  subnet_availability_zone_option = local.use_az_ids ? "from_az_ids" : (
    local.use_az_var ? "from_az_var" : "all_azs"
  )

  subnet_possible_availability_zones = local.az_option_map[local.subnet_availability_zone_option]

  # Adjust list according to `max_az_count`
  subnet_availability_zones = (
    local.max_az_count == 0 || local.max_az_count >= length(local.subnet_possible_availability_zones)
    ) ? (
    local.subnet_possible_availability_zones
  ) : slice(local.subnet_possible_availability_zones, 0, local.max_az_count)

  subnet_az_count = var.module_enabled ? length(local.subnet_availability_zones) : 0

  all_route_table_ids = concat(local.private_route_table_ids, local.public_route_table_ids, [])

  module_tags = tomap({
    tf_sub_module = "aws-anyscale-vpc"
  })
}

# ------------------------
# Top Level VPC Resources
# ------------------------

#trivy:ignore:avd-aws-0178:Flow logs can be enabled via a boolean variable. Ignoring this alert.
resource "aws_vpc" "anyscale_vpc" {
  #checkov:skip=CKV2_AWS_12:Not managing the default security group in this module
  #checkov:skip=CKV2_AWS_11:Flow logs can be enabled via a boolean variable. Ignoring this alert.
  count = local.create_vpc ? 1 : 0

  cidr_block          = var.use_ipam_pool ? null : var.cidr_block
  ipv4_ipam_pool_id   = var.ipv4_ipam_pool_id
  ipv4_netmask_length = var.ipv4_netmask_length

  instance_tenancy     = var.vpc_instance_tenancy
  enable_dns_hostnames = var.enable_vpc_dns_hostnames
  enable_dns_support   = var.enable_vpc_dns_support

  tags = merge(
    { "Name" = local.vpc_name },
    local.module_tags,
    var.tags
  )
}

resource "aws_vpc_ipv4_cidr_block_association" "anyscale_vpc" {
  count = var.module_enabled && length(var.secondary_cidr_blocks) > 0 ? length(var.secondary_cidr_blocks) : 0

  # Do not turn this into `local.vpc_id`
  vpc_id = aws_vpc.anyscale_vpc[0].id

  cidr_block = element(var.secondary_cidr_blocks, count.index)
}


# --------------
# VPC Flow Logs
# --------------
resource "aws_flow_log" "anyscale_vpc" {
  count = var.module_enabled && var.enable_vpc_flow_logs ? 1 : 0

  iam_role_arn    = aws_iam_role.anyscale_vpc_flow_log[0].arn
  log_destination = aws_cloudwatch_log_group.anyscale_vpc[0].arn
  traffic_type    = "ALL"
  vpc_id          = local.vpc_id

  tags = merge(
    local.module_tags,
    var.tags
  )
}


#trivy:ignore:avd-aws-0017
resource "aws_cloudwatch_log_group" "anyscale_vpc" {
  #checkov:skip=CKV_AWS_338:Cloudwatch Log Group retention is variable.
  count = var.module_enabled && var.create_flow_log_cloudwatch_log_group ? 1 : 0

  name = format(
    "${var.flow_log_cloudwatch_log_group_name_prefix}%s",
    coalesce(var.flow_log_cloudwatch_log_group_name_suffix, local.vpc_name)
  )
  retention_in_days = var.flow_log_cloudwatch_log_group_retention_in_days
  kms_key_id        = var.flow_log_cloudwatch_log_group_kms_key_id

  tags = merge(
    local.module_tags,
    var.tags
  )
}

resource "aws_iam_role" "anyscale_vpc_flow_log" {
  count = var.module_enabled && var.create_flow_log_cloudwatch_iam_role ? 1 : 0

  name_prefix          = "${local.vpc_name}-flow-log-role-"
  assume_role_policy   = data.aws_iam_policy_document.flow_log_cloudwatch_assume_role[0].json
  permissions_boundary = var.vpc_flow_log_permissions_boundary

  tags = merge(
    local.module_tags,
    var.tags
  )
}

data "aws_iam_policy_document" "flow_log_cloudwatch_assume_role" {
  count = var.module_enabled && var.create_flow_log_cloudwatch_iam_role ? 1 : 0

  statement {
    sid = "AWSVPCFlowLogsAssumeRole"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    effect = "Allow"

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "vpc_flow_log_cloudwatch" {
  count = var.module_enabled && var.create_flow_log_cloudwatch_iam_role ? 1 : 0

  role       = aws_iam_role.anyscale_vpc_flow_log[0].name
  policy_arn = aws_iam_policy.vpc_flow_log_cloudwatch[0].arn
}

resource "aws_iam_policy" "vpc_flow_log_cloudwatch" {
  count = var.module_enabled && var.create_flow_log_cloudwatch_iam_role ? 1 : 0

  name_prefix = "vpc-flow-log-to-cloudwatch-"
  policy      = data.aws_iam_policy_document.vpc_flow_log_cloudwatch[0].json

  tags = merge(
    local.module_tags,
    var.tags
  )
}

#trivy:ignore:avd-aws-0057
data "aws_iam_policy_document" "vpc_flow_log_cloudwatch" {
  #checkov:skip=CKV_AWS_356:Wildcard resource allowed in IAM policy
  count = var.module_enabled && var.create_flow_log_cloudwatch_iam_role ? 1 : 0

  #checkov:skip=CKV_AWS_111:Log permissions required for Flow Logs
  statement {
    sid = "AWSVPCFlowLogsPushToCloudWatch"

    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["*"]
  }
}
