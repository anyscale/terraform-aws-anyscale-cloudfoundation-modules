#----------------------------
#- Creates Anyscale IAM Roles and Policies
data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id

  # Prioritize external_id over cloud_id for trust policy
  trust_policy_external_id  = var.anyscale_external_id != null ? [var.anyscale_external_id] : (var.anyscale_cloud_id != null ? [var.anyscale_cloud_id] : [])
  role_sts_externalid       = length(var.anyscale_trusted_role_sts_externalid) > 0 ? flatten([var.anyscale_trusted_role_sts_externalid]) : local.trust_policy_external_id
  anyscale_access_role_desc = var.anyscale_access_role_description != null ? var.anyscale_access_role_description : var.anyscale_cloud_id != null ? "Anyscale Control Plane Role  for cloud ${var.anyscale_cloud_id}" : "Anyscale Control Plane role"
  anyscale_access_role_name = try(var.anyscale_access_role_name, null)
  anyscale_role_prefix      = local.anyscale_access_role_name != null ? null : var.anyscale_access_role_name_prefix != null ? var.anyscale_access_role_name_prefix : "anyscale-"

  create_steady_state_policy                = var.create_anyscale_access_role == true && var.create_anyscale_access_steadystate_policy == true ? true : false
  anyscale_access_steadystate_policy_name   = try(var.anyscale_access_steadystate_policy_name, null)
  anyscale_access_steadystate_policy_prefix = local.anyscale_access_steadystate_policy_name != null ? null : var.anyscale_access_steadystate_policy_prefix != null ? var.anyscale_access_steadystate_policy_prefix : "anyscsale-"

  create_servicesv2_policy          = var.create_anyscale_access_role && var.create_anyscale_access_servicesv2_policy ? true : false
  anyscale_servicesv2_policy_name   = try(var.anyscale_access_servicesv2_policy_name, null)
  anyscale_servicesv2_policy_prefix = local.anyscale_servicesv2_policy_name != null ? null : var.anyscale_access_servicesv2_policy_prefix != null ? var.anyscale_access_servicesv2_policy_prefix : "anyscale-servicesv2-"

  create_secrets_policy = var.module_enabled && (length(var.anyscale_cluster_node_byod_secret_arns) > 0 || var.anyscale_cluster_node_byod_custom_secrets_policy != null) ? true : false

  create_s3_bucket_access_policy     = var.module_enabled && var.create_iam_s3_policy ? true : false
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

  anyscale_cluster_node_secrets_policy_name   = try(var.anyscale_cluster_node_byod_secrets_policy_name, null)
  anyscale_cluster_node_secrets_policy_prefix = local.anyscale_cluster_node_secrets_policy_name != null ? null : var.anyscale_cluster_node_byod_secrets_policy_prefix != null ? var.anyscale_cluster_node_byod_secrets_policy_prefix : "anyscale-cluster-secrets-"

  anyscale_cluster_node_assume_role_policy = var.anyscale_cluster_node_custom_assume_role_policy == null ? data.aws_iam_policy_document.iam_anyscale_cluster_node_assumerole_policy.json : var.anyscale_cluster_node_custom_assume_role_policy
}
resource "aws_iam_role" "anyscale_cluster_node_role" {
  count = var.module_enabled && var.create_cluster_node_instance_profile ? 1 : 0

  name        = local.anyscale_cluster_node_role_name
  name_prefix = local.anyscale_cluster_node_role_name_prefix
  path        = var.anyscale_cluster_node_role_path
  description = var.anyscale_cluster_node_role_description

  permissions_boundary = var.role_permissions_boundary_arn
  assume_role_policy   = local.anyscale_cluster_node_assume_role_policy

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

#trivy:ignore:avd-aws-0057:Wildcard may be passed in IAM policy
resource "aws_iam_policy" "anyscale_cluster_node_custom_policy" {
  #checkov:skip=CKV_AWS_355:Policy requires wildcards in resource permissions
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

resource "aws_iam_policy" "anyscale_cluster_node_secretsmanager_policy" {
  count = local.create_secrets_policy ? 1 : 0

  name        = local.anyscale_cluster_node_secrets_policy_name
  name_prefix = local.anyscale_cluster_node_secrets_policy_prefix
  path        = var.anyscale_cluster_node_byod_secrets_policy_path
  description = var.anyscale_cluster_node_byod_secrets_policy_description
  # policy      = local.secrets_policy_body
  policy = one(data.aws_iam_policy_document.cluster_node_secretmanager_read_access[*].json)

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

resource "aws_iam_role_policy_attachment" "anyscale_cluster_node_secretsmanager_policy_attach" {
  count = var.module_enabled && local.create_secrets_policy ? 1 : 0

  role       = one(aws_iam_role.anyscale_cluster_node_role[*].name)
  policy_arn = one(aws_iam_policy.anyscale_cluster_node_secretsmanager_policy[*].arn)
}

# S3 Policy and attachments
resource "aws_iam_policy" "anyscale_s3_access_policy" {
  count = local.create_s3_bucket_access_policy ? 1 : 0

  name        = var.anyscale_iam_s3_policy_name
  name_prefix = local.anyscale_iam_s3_policy_name_prefix
  path        = var.anyscale_iam_s3_policy_path
  description = var.anyscale_iam_s3_policy_description
  policy      = data.aws_iam_policy_document.iam_anyscale_s3_bucket_access[0].json

  tags = merge(
    local.module_tags,
    var.tags,
  )
}

resource "aws_iam_role_policy_attachment" "anyscale_cluster_node_s3_policy_attach" {
  count = var.module_enabled && var.create_cluster_node_instance_profile && local.create_s3_bucket_access_policy ? 1 : 0

  role       = aws_iam_role.anyscale_cluster_node_role[0].name
  policy_arn = aws_iam_policy.anyscale_s3_access_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "anyscale_access_role_s3_policy_attach" {
  count = var.module_enabled && var.create_anyscale_access_role && local.create_s3_bucket_access_policy ? 1 : 0

  role       = aws_iam_role.anyscale_access_role[0].name
  policy_arn = aws_iam_policy.anyscale_s3_access_policy[0].arn
}
