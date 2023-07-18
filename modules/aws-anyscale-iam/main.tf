#----------------------------
#- Creates Anyscale IAM Roles and Policies
data "aws_caller_identity" "current" {}
# data "aws_partition" "current" {}
data "aws_region" "current" {}

locals {
  account_id  = data.aws_caller_identity.current.account_id
  region_name = data.aws_region.current.name

  role_sts_externalid       = flatten([var.anyscale_trusted_role_sts_externalid])
  anyscale_access_role_desc = var.anyscale_access_role_description != null ? var.anyscale_access_role_description : var.anyscale_cloud_id != null ? "Anyscale access role for cloud ${var.anyscale_cloud_id} in region ${local.region_name}" : "Anyscale access role"
  anyscale_access_role_name = try(var.anyscale_access_role_name, null)
  anyscale_role_prefix      = local.anyscale_access_role_name != null ? null : var.anyscale_access_role_name_prefix != null ? var.anyscale_access_role_name_prefix : "anyscale-"

  create_steady_state_policy                = var.create_anyscale_access_role == true && var.create_anyscale_access_steadystate_policy == true ? true : false
  anyscale_access_steadystate_policy_name   = try(var.anyscale_access_steadystate_policy_name, null)
  anyscale_access_steadystate_policy_prefix = local.anyscale_access_steadystate_policy_name != null ? null : var.anyscale_access_steadystate_policy_prefix != null ? var.anyscale_access_steadystate_policy_prefix : "anyscsale-"

  create_servicesv2_policy          = var.create_anyscale_access_role && var.create_anyscale_access_servicesv2_policy ? true : false
  anyscale_servicesv2_policy_name   = try(var.anyscale_access_servicesv2_policy_name, null)
  anyscale_servicesv2_policy_prefix = local.anyscale_servicesv2_policy_name != null ? null : var.anyscale_access_servicesv2_policy_prefix != null ? var.anyscale_access_servicesv2_policy_prefix : "anyscale-servicesv2-"
  # split_cloudid                     = try(split("_", var.anyscale_cloud_id), [])
  # capitalized_cloudid_parts = [
  #   for part in local.split_cloudid : "${upper(substr(part, 0, 1))}${substr(part, 1, -1)}"
  # ]
  # joined_cloudid         = try(substr(join("", local.capitalized_cloudid_parts), 0, 19), null)
  # servicev2_policy_cldid = try("AnyscaleALB${local.joined_cloudid}", "*")

  create_s3_bucket_policy            = var.anyscale_s3_bucket_arn != null ? true : false
  anyscale_iam_s3_policy_name_cld_id = var.anyscale_cloud_id != null && var.anyscale_iam_s3_policy_name_prefix == null && var.anyscale_iam_s3_policy_name == null ? "anyscale-${var.anyscale_cloud_id}-s3-" : null
  anyscale_iam_s3_policy_name_prefix = var.anyscale_iam_s3_policy_name != null ? null : local.anyscale_iam_s3_policy_name_cld_id == null ? var.anyscale_iam_s3_policy_name_prefix : local.anyscale_iam_s3_policy_name_cld_id != null ? local.anyscale_iam_s3_policy_name_cld_id : "anyscale-s3-"

  create_custom_policy          = var.anyscale_custom_policy != null ? true : false
  anyscale_custom_policy_name   = try(var.anyscale_custom_policy_name, null)
  anyscale_custom_policy_prefix = local.anyscale_custom_policy_name != null ? null : var.anyscale_custom_policy_name_prefix != null ? var.anyscale_custom_policy_name_prefix : "anyscale-"

  module_tags = tomap({
    tf_sub_module = "aws-anyscale-iam"
  })
}

# -------------------------
# Anyscale IAM Access Role
# -------------------------
resource "aws_iam_role" "anyscale_access_role" {
  count = var.module_enabled && var.create_anyscale_access_role ? 1 : 0

  name        = local.anyscale_access_role_name
  name_prefix = local.anyscale_role_prefix
  path        = var.anyscale_access_role_path
  description = local.anyscale_access_role_desc

  permissions_boundary = var.role_permissions_boundary_arn
  assume_role_policy   = data.aws_iam_policy_document.iam_anyscale_crossacct_assumerole_policy.json

  tags = merge(
    local.module_tags,
    var.tags,
  )
}

resource "aws_iam_policy" "anyscale_steadystate_policy" {
  count = var.module_enabled && local.create_steady_state_policy ? 1 : 0

  name        = local.anyscale_access_steadystate_policy_name
  name_prefix = local.anyscale_access_steadystate_policy_prefix
  path        = var.anyscale_access_steadystate_policy_path
  description = var.anyscale_access_steadystate_policy_description
  policy      = data.aws_iam_policy_document.iam_anyscale_steadystate_policy.json

  tags = var.tags
}

resource "aws_iam_policy" "anyscale_servicesv2_policy" {
  count = var.module_enabled && local.create_servicesv2_policy ? 1 : 0

  name        = local.anyscale_servicesv2_policy_name
  name_prefix = local.anyscale_servicesv2_policy_prefix
  path        = var.anyscale_access_servicesv2_policy_path
  description = var.anyscale_access_servicesv2_policy_description
  policy      = data.aws_iam_policy_document.iam_anyscale_services_v2.json

  tags = var.tags
}

resource "aws_iam_policy" "anyscale_iam_custom_policy" {
  count = var.module_enabled && local.create_custom_policy ? 1 : 0

  name        = local.anyscale_custom_policy_name
  name_prefix = local.anyscale_custom_policy_prefix
  path        = var.anyscale_custom_policy_path
  description = var.anyscale_custom_policy_description
  policy      = var.anyscale_custom_policy

  tags = var.tags
}

# Policy attachments
resource "aws_iam_role_policy_attachment" "anyscale_iam_role_steady_state_policy_attach" {
  count = var.module_enabled && local.create_steady_state_policy ? 1 : 0

  role       = aws_iam_role.anyscale_access_role[0].name
  policy_arn = aws_iam_policy.anyscale_steadystate_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "anyscale_iam_role_servicesv2_policy_attach" {
  count = var.module_enabled && local.create_servicesv2_policy ? 1 : 0

  role       = aws_iam_role.anyscale_access_role[0].name
  policy_arn = aws_iam_policy.anyscale_servicesv2_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "anyscale_iam_role_custom_policy_attach" {
  count = var.module_enabled && var.create_anyscale_access_role && local.create_custom_policy ? 1 : 0

  role       = aws_iam_role.anyscale_access_role[0].name
  policy_arn = aws_iam_policy.anyscale_iam_custom_policy[0].arn
}


resource "aws_iam_role_policy_attachment" "anyscale_iam_role_container_registry_policy_attach" {
  count = var.module_enabled && var.create_anyscale_access_role && var.enable_ec2_container_registry_readonly_access ? 1 : 0

  role       = aws_iam_role.anyscale_access_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "managed_policy_attachment" {
  count = var.module_enabled && var.create_anyscale_access_role ? length(var.anyscale_access_managed_policy_arns) : 0

  role       = aws_iam_role.anyscale_access_role[0].name
  policy_arn = var.anyscale_access_managed_policy_arns[count.index]
}

# ---------------------------
# Anyscale Cluster Node Role
#  & Instance Profile
# ---------------------------
locals {
  create_cluster_node_custom_policy = var.anyscale_cluster_node_custom_policy != null ? true : false

  anyscale_cluster_node_role_name        = try(var.anyscale_cluster_node_role_name, null)
  anyscale_cluster_node_role_name_prefix = local.anyscale_cluster_node_role_name != null ? null : var.anyscale_cluster_node_role_name_prefix != null ? var.anyscale_cluster_node_role_name_prefix : "anyscale-cluster-node-"

  anyscale_cluster_node_custom_policy_name   = try(var.anyscale_cluster_node_custom_policy_name, null)
  anyscale_cluster_node_custom_policy_prefix = local.anyscale_cluster_node_custom_policy_name != null ? null : var.anyscale_cluster_node_custom_policy_prefix != null ? var.anyscale_cluster_node_custom_policy_prefix : "anyscale-cluster-node-"

  anyscale_cluster_node_cloudwatch_policy_name   = try(var.anyscale_cluster_node_cloudwatch_policy_name, null)
  anyscale_cluster_node_cloudwatch_policy_prefix = local.anyscale_cluster_node_cloudwatch_policy_name != null ? null : var.anyscale_cluster_node_cloudwatch_policy_prefix != null ? var.anyscale_cluster_node_cloudwatch_policy_prefix : "anyscale-cluster-cloudwatch-"
}
resource "aws_iam_role" "anyscale_cluster_node_role" {
  count = var.module_enabled && var.create_cluster_node_instance_profile ? 1 : 0

  name        = local.anyscale_cluster_node_role_name
  name_prefix = local.anyscale_cluster_node_role_name_prefix
  path        = var.anyscale_cluster_node_role_path
  description = var.anyscale_cluster_node_role_description

  permissions_boundary = var.role_permissions_boundary_arn
  assume_role_policy   = data.aws_iam_policy_document.iam_anyscale_cluster_node_assumerole_policy.json

  tags = merge(
    local.module_tags,
    var.tags,
  )

}

resource "aws_iam_instance_profile" "anyscale_cluster_node_role" {
  count = var.module_enabled && var.create_cluster_node_instance_profile ? 1 : 0

  name = aws_iam_role.anyscale_cluster_node_role[0].name
  path = var.anyscale_cluster_node_role_path
  role = aws_iam_role.anyscale_cluster_node_role[0].name

  # tags = var.tags
}


resource "aws_iam_policy" "anyscale_cluster_node_custom_policy" {
  count = var.module_enabled && local.create_cluster_node_custom_policy ? 1 : 0

  name        = local.anyscale_cluster_node_custom_policy_name
  name_prefix = local.anyscale_cluster_node_custom_policy_prefix
  path        = var.anyscale_cluster_node_custom_policy_path
  description = var.anyscale_cluster_node_custom_policy_description
  policy      = var.anyscale_cluster_node_custom_policy

  tags = merge(
    local.module_tags,
    var.tags,
  )
}

resource "aws_iam_policy" "anyscale_cluster_node_cloudwatch_policy" {
  count = var.module_enabled && var.create_cluster_node_cloudwatch_policy ? 1 : 0

  name        = local.anyscale_cluster_node_cloudwatch_policy_name
  name_prefix = local.anyscale_cluster_node_cloudwatch_policy_prefix
  path        = var.anyscale_cluster_node_cloudwatch_policy_path
  description = var.anyscale_cluster_node_cloudwatch_policy_description
  policy      = data.aws_iam_policy_document.cluster_node_cloudwatch_access.json

  tags = merge(
    local.module_tags,
    var.tags,
  )
}

# Policy attachments
resource "aws_iam_role_policy_attachment" "anyscale_cluster_node_container_registry_policy_attach" {
  count = var.module_enabled && var.enable_ec2_container_registry_readonly_access && var.create_cluster_node_instance_profile ? 1 : 0

  role       = aws_iam_role.anyscale_cluster_node_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "anyscale_cluster_node_custom_policy_attach" {
  count = var.module_enabled && local.create_cluster_node_custom_policy ? 1 : 0

  role       = aws_iam_role.anyscale_cluster_node_role[0].name
  policy_arn = aws_iam_policy.anyscale_cluster_node_custom_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "anyscale_cluster_node_managed_policy_attach" {
  count = var.module_enabled && var.create_cluster_node_instance_profile ? length(var.anyscale_cluster_node_managed_policy_arns) : 0

  role       = aws_iam_role.anyscale_cluster_node_role[0].name
  policy_arn = var.anyscale_cluster_node_managed_policy_arns[count.index]
}

resource "aws_iam_role_policy_attachment" "anyscale_cluster_node_cloudwatch_policy_attach" {
  count = var.module_enabled && var.create_cluster_node_cloudwatch_policy ? 1 : 0

  role       = aws_iam_role.anyscale_cluster_node_role[0].name
  policy_arn = aws_iam_policy.anyscale_cluster_node_cloudwatch_policy[0].arn
}

# S3 Policy and attachments
resource "aws_iam_policy" "anyscale_s3_access_policy" {
  count = var.module_enabled && var.create_iam_s3_policy ? 1 : 0

  name        = var.anyscale_iam_s3_policy_name
  name_prefix = local.anyscale_iam_s3_policy_name_prefix
  path        = var.anyscale_iam_s3_policy_path
  description = var.anyscale_iam_s3_policy_description
  policy      = data.aws_iam_policy_document.iam_anyscale_s3_bucket_access.json

  tags = merge(
    local.module_tags,
    var.tags,
  )
}

resource "aws_iam_role_policy_attachment" "anyscale_cluster_node_s3_policy_attach" {
  count = var.module_enabled && var.create_cluster_node_instance_profile && var.create_iam_s3_policy ? 1 : 0

  role       = aws_iam_role.anyscale_cluster_node_role[0].name
  policy_arn = aws_iam_policy.anyscale_s3_access_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "anyscale_access_role_s3_policy_attach" {
  count = var.module_enabled && var.create_anyscale_access_role && var.create_iam_s3_policy ? 1 : 0

  role       = aws_iam_role.anyscale_access_role[0].name
  policy_arn = aws_iam_policy.anyscale_s3_access_policy[0].arn
}

# ---------------------------
# Service Linked Role
#   - Elastic Load Balancing
# ---------------------------
# resource "aws_iam_service_linked_role" "elastic_load_balancing" {
#   count            = local.create_alb_linked_role ? 1 : 0
#   aws_service_name = "elasticloadbalancing.amazonaws.com"
# }
