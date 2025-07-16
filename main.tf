# ---------------------------------------------------------------------------------------------------------------------
# Core Anyscale AWS Module
#  This creates the foundational AWS resources required for an Anyscale Cloud
#  This module is the root module and calls other modules to create the resources
# ---------------------------------------------------------------------------------------------------------------------
locals {
  full_tags = merge(tomap({
    anyscale-cloud-id           = var.anyscale_cloud_id,
    anyscale-org-id             = var.anyscale_org_id,
    anyscale-deploy-environment = var.anyscale_deploy_env
    tf_module                   = "anyscale-cloudfoundations"
    }),
    var.tags
  )

  iam_tags           = merge(local.full_tags, var.anyscale_iam_tags)
  securitygroup_tags = merge(local.full_tags, var.anyscale_securitygroup_tags)
  efs_tags           = merge(local.full_tags, var.anyscale_efs_tags)
  s3_tags            = merge(local.full_tags, var.anyscale_s3_tags)

  create_new_s3_bucket = var.existing_s3_bucket_arn == null ? true : false

  s3_bucket_prefix                  = coalesce(var.anyscale_s3_bucket_prefix, var.common_prefix, "anyscale-")
  iam_access_role_name_prefix       = coalesce(var.anyscale_iam_access_role_name_prefix, var.common_prefix, "anyscale-iam-role-")
  iam_cluster_node_role_name_prefix = coalesce(var.anyscale_iam_cluster_node_role_name_prefix, var.common_prefix, "anyscale-cluster-node-")
  steadystate_policy_prefix         = coalesce(var.anyscale_access_steadystate_policy_prefix, var.common_prefix, "anyscale-steady_state-")
  iam_servicesv2_policy_prefix      = coalesce(var.anyscale_access_servicesv2_policy_prefix, var.common_prefix, "anyscale-servicesv2-")
  cluster_node_custom_policy_prefix = coalesce(var.anyscale_cluster_node_custom_policy_prefix, var.common_prefix, "anyscale-clusternode-custom-policy-")
  access_role_custom_policy_prefix  = coalesce(var.anyscale_accessrole_custom_policy_name_prefix, var.common_prefix, "anyscale-crossacct-custom-policy-")
  iam_s3_policy_prefix              = coalesce(var.anyscale_iam_s3_policy_name_prefix, var.common_prefix, "anyscale-iam-s3-")

  common_name_prefix = var.use_common_name ? coalesce(var.common_prefix, "anyscale-") : null
}

# ------------------------------
# Common Name Random ID
# ------------------------------
resource "random_id" "common_name" {
  count = var.use_common_name ? 1 : 0

  byte_length = var.random_name_suffix_length
  prefix      = local.common_name_prefix
}

locals {
  common_name    = try(random_id.common_name[0].hex, null)
  s3_bucket_name = var.anyscale_s3_bucket_name != null ? var.anyscale_s3_bucket_name : local.common_name
  efs_name       = var.anyscale_efs_name != null ? var.anyscale_efs_name : local.common_name

  # IAM Role Names/Policies are unique since we have multiples of these for a given Anyscale Cloud.
  # For IAM Roles and Policies, we'll add the type of role/policy to the name.
  iam_access_role_name                = var.anyscale_iam_access_role_name != null ? var.anyscale_iam_access_role_name : local.common_name != null ? "${local.common_name}-crossacct-iam-role" : null
  iam_cluster_node_role_name          = var.anyscale_iam_cluster_node_role_name != null ? var.anyscale_iam_cluster_node_role_name : local.common_name != null ? "${local.common_name}-cluster-node-role" : null
  iam_steadystate_policy_name         = var.anyscale_access_steadystate_policy_name != null ? var.anyscale_access_steadystate_policy_name : local.common_name != null ? "${local.common_name}-crossacct-steadystate-policy" : null
  iam_servicesv2_policy_name          = var.anyscale_access_servicesv2_policy_name != null ? var.anyscale_access_servicesv2_policy_name : local.common_name != null ? "${local.common_name}-crossacct-servicesv2-policy" : null
  iam_cluster_node_custom_policy_name = var.anyscale_cluster_node_custom_policy_name != null ? var.anyscale_cluster_node_custom_policy_name : local.common_name != null ? "${local.common_name}-clusternode-custom-policy" : null
  cluster_node_cloudwatch_policy_name = var.anyscale_cluster_node_cloudwatch_policy_name != null ? var.anyscale_cluster_node_cloudwatch_policy_name : local.common_name != null ? "${local.common_name}-clusternode-cloudwatch-policy" : null
  cluster_node_cloudwatch_policy_prfx = var.anyscale_cluster_node_cloudwatch_policy_prefix != null ? var.anyscale_cluster_node_cloudwatch_policy_prefix : local.common_name != null ? "${local.common_name}-clusternode-cloudwatch-policy-" : null
  iam_accessrole_custom_policy_name   = var.anyscale_accessrole_custom_policy_name != null ? var.anyscale_accessrole_custom_policy_name : local.common_name != null ? "${local.common_name}-crossacct-custom-policy" : null
  iam_s3_policy_name                  = var.anyscale_iam_s3_policy_name != null ? var.anyscale_iam_s3_policy_name : local.common_name != null ? "${local.common_name}-s3-policy" : null
  iam_cluster_node_secrets_plcy_name  = var.anyscale_cluster_node_byod_secrets_policy_name != null ? var.anyscale_cluster_node_byod_secrets_policy_name : local.common_name != null ? "${local.common_name}-clusternode-secrets-policy" : null
  iam_cluster_node_secrets_plcy_prfx  = var.anyscale_cluster_node_byod_secrets_policy_prefix != null ? var.anyscale_cluster_node_byod_secrets_policy_prefix : local.common_name != null ? "${local.common_name}-clusternode-secrets-" : null

  # Construct external ID with org prefix if both are provided
  external_id_with_org_id = var.anyscale_external_id != null && var.anyscale_org_id != null ? "${var.anyscale_org_id}-${var.anyscale_external_id}" : null
  # Prioritize external_id over cloud_id for trust policy
  iam_assume_role_external_id = var.anyscale_external_id != null ? [local.external_id_with_org_id] : (var.anyscale_cloud_id != null && var.anyscale_cloud_id != "" ? [var.anyscale_cloud_id] : [])
}

# ------------------------------
# S3 Module
# ------------------------------
module "aws_anyscale_s3" {
  source = "./modules/aws-anyscale-s3"
  tags   = local.s3_tags

  anyscale_cloud_id      = var.anyscale_cloud_id
  anyscale_bucket_name   = local.s3_bucket_name
  anyscale_bucket_prefix = local.s3_bucket_prefix
  server_side_encryption = var.anyscale_s3_server_side_encryption
  force_destroy          = var.anyscale_s3_force_destroy
  lifecycle_rule         = var.anyscale_s3_lifecycle_rule

  module_enabled = local.create_new_s3_bucket
}

# ------------------------------
# IAM Module
# ------------------------------
module "aws_anyscale_iam" {
  source = "./modules/aws-anyscale-iam"
  tags   = local.iam_tags

  anyscale_access_role_name        = local.iam_access_role_name
  anyscale_access_role_name_prefix = local.iam_access_role_name_prefix
  anyscale_access_role_description = var.anyscale_access_role_description

  anyscale_access_steadystate_policy_name        = local.iam_steadystate_policy_name
  anyscale_access_steadystate_policy_prefix      = local.steadystate_policy_prefix
  anyscale_access_steadystate_policy_description = var.anyscale_access_steadystate_policy_description

  anyscale_access_servicesv2_policy_name        = local.iam_servicesv2_policy_name
  anyscale_access_servicesv2_policy_prefix      = local.iam_servicesv2_policy_prefix
  anyscale_access_servicesv2_policy_description = var.anyscale_access_servicesv2_policy_description

  anyscale_trusted_role_arns = var.anyscale_access_role_trusted_role_arns

  anyscale_custom_policy_name        = local.iam_accessrole_custom_policy_name
  anyscale_custom_policy_name_prefix = local.access_role_custom_policy_prefix
  anyscale_custom_policy_description = var.anyscale_accessrole_custom_policy_description
  anyscale_custom_policy             = var.anyscale_accessrole_custom_policy

  anyscale_cluster_node_role_name        = local.iam_cluster_node_role_name
  anyscale_cluster_node_role_name_prefix = local.iam_cluster_node_role_name_prefix
  anyscale_cluster_node_role_description = var.anyscale_cluster_node_role_description

  anyscale_cluster_node_custom_assume_role_policy = var.anyscale_cluster_node_custom_assume_role_policy

  create_cluster_node_cloudwatch_policy               = var.create_cluster_node_cloudwatch_policy
  anyscale_cluster_node_cloudwatch_policy_name        = local.cluster_node_cloudwatch_policy_name
  anyscale_cluster_node_cloudwatch_policy_prefix      = local.cluster_node_cloudwatch_policy_prfx
  anyscale_cluster_node_cloudwatch_policy_description = var.anyscale_cluster_node_cloudwatch_policy_description

  anyscale_cluster_node_custom_policy_name        = local.iam_cluster_node_custom_policy_name
  anyscale_cluster_node_custom_policy_prefix      = local.cluster_node_custom_policy_prefix
  anyscale_cluster_node_custom_policy_description = var.anyscale_cluster_node_custom_policy_description
  anyscale_cluster_node_custom_policy             = var.anyscale_cluster_node_custom_policy

  anyscale_cluster_node_byod_secrets_policy_name        = local.iam_cluster_node_secrets_plcy_name
  anyscale_cluster_node_byod_secrets_policy_prefix      = local.iam_cluster_node_secrets_plcy_prfx
  anyscale_cluster_node_byod_secrets_policy_description = var.anyscale_cluster_node_byod_secrets_policy_description
  anyscale_cluster_node_byod_custom_secrets_policy      = var.anyscale_cluster_node_byod_custom_secrets_policy
  anyscale_cluster_node_byod_secret_arns                = var.anyscale_cluster_node_byod_secret_arns
  anyscale_cluster_node_byod_secret_kms_arn             = var.anyscale_cluster_node_byod_secret_kms_arn

  anyscale_cluster_node_managed_policy_arns = var.anyscale_cluster_node_managed_policy_arns

  create_iam_s3_policy               = local.create_new_s3_bucket || var.existing_s3_bucket_arn != null ? true : false
  anyscale_s3_bucket_arn             = try(coalesce(var.existing_s3_bucket_arn, module.aws_anyscale_s3.s3_bucket_arn), null)
  anyscale_iam_s3_policy_name        = local.iam_s3_policy_name
  anyscale_iam_s3_policy_name_prefix = local.iam_s3_policy_prefix
  anyscale_iam_s3_policy_description = var.anyscale_iam_s3_policy_description

  anyscale_trusted_role_sts_externalid = local.iam_assume_role_external_id

  anyscale_cloud_id    = var.anyscale_cloud_id
  anyscale_org_id      = var.anyscale_org_id
  anyscale_external_id = local.external_id_with_org_id
}

# ------------------------------
# S3 Policy Module
# ------------------------------
module "aws_anyscale_s3_policy" {
  source = "./modules/aws-anyscale-s3-policy"

  anyscale_bucket_name           = module.aws_anyscale_s3.s3_bucket_id
  anyscale_controlplane_role_arn = module.aws_anyscale_iam.iam_anyscale_access_role_arn
  anyscale_dataplane_role_arn    = module.aws_anyscale_iam.iam_cluster_node_role_arn

  custom_s3_policy = var.anyscale_custom_s3_policy

  module_enabled = local.create_new_s3_bucket
}

# ------------------------------
# VPC (Networking) Module
# ------------------------------
locals {
  vpc_name_from_prefix = var.common_prefix != null && try(length(var.common_prefix), 0) > 0 && (try(substr(var.common_prefix, -1, 1), null) == "-" || try(substr(var.common_prefix, -1, 1), null) == "_") ? substr(var.common_prefix, 0, length(var.common_prefix) - 1) : var.common_prefix
  vpc_name             = coalesce(var.anyscale_vpc_name, local.common_name, local.vpc_name_from_prefix, "vpc-anyscale")
  vpc_tags             = merge(local.full_tags, var.anyscale_vpc_tags)

  anyscale_private_subnet_count = length(var.anyscale_vpc_private_subnets)
  anyscale_public_subnet_count  = length(var.anyscale_vpc_public_subnets)

  create_new_vpc              = var.existing_vpc_id == null ? true : false
  create_vpc_subnets          = local.anyscale_private_subnet_count > 0 || local.anyscale_public_subnet_count > 0 ? true : false
  create_vpc_gateway_endpoint = length(var.anyscale_gateway_vpc_endpoints) > 0 && (local.create_new_vpc || length(var.existing_vpc_private_route_table_ids) > 0 || length(var.existing_vpc_public_route_table_ids) > 0) ? true : false
  create_internet_gw          = local.create_new_vpc ? true : false
  create_nat_gw               = local.create_new_vpc ? true : false
  execute_vpc_sub_module      = local.create_new_vpc || local.create_vpc_subnets || local.create_vpc_gateway_endpoint ? true : false
}
module "aws_anyscale_vpc" {
  source = "./modules/aws-anyscale-vpc"
  tags   = local.vpc_tags

  anyscale_vpc_name = local.vpc_name
  cidr_block        = var.anyscale_vpc_cidr_block

  public_subnets      = var.anyscale_vpc_public_subnets
  public_subnet_tags  = var.anyscale_vpc_public_subnet_tags
  private_subnets     = var.anyscale_vpc_private_subnets
  private_subnet_tags = var.anyscale_vpc_private_subnet_tags

  create_igw = local.create_internet_gw
  create_ngw = local.create_nat_gw

  gateway_vpc_endpoints = var.anyscale_gateway_vpc_endpoints

  existing_vpc_id                  = var.existing_vpc_id
  existing_private_subnet_ids      = var.existing_vpc_subnet_ids
  existing_private_route_table_ids = var.existing_vpc_private_route_table_ids
  existing_public_route_table_ids  = var.existing_vpc_public_route_table_ids

  module_enabled = local.execute_vpc_sub_module
}

# ------------------------------
# Security Group Module
# ------------------------------
locals {
  ingress_cidr_block_defined = length(var.security_group_ingress_allow_access_from_cidr_range) > 1 ? true : false
  ingress_from_cidr_map = concat([
    {
      rule        = "https-443-tcp"
      cidr_blocks = var.security_group_ingress_allow_access_from_cidr_range
    }
    ], var.security_group_enable_ssh_access ? [
    {
      rule        = "ssh-tcp"
      cidr_blocks = var.security_group_ingress_allow_access_from_cidr_range
    }
  ] : [])
  ingress_from_cidr_range_override_defined = length(var.security_group_override_ingress_from_cidr_map) > 1 ? true : false

  ingress_existing_sg_defined = length(var.security_group_ingress_with_existing_security_groups_map) > 1 ? true : false

  security_group_name            = var.security_group_name != null ? var.security_group_name : local.common_name
  security_group_name_prefix     = coalesce(var.security_group_name_prefix, var.common_prefix, "anyscale-security-group-")
  amp_security_group_name        = var.anyscale_machine_pool_security_group_name != null ? var.anyscale_machine_pool_security_group_name : local.common_name != null ? "${local.common_name}-machine-pool-sg" : null
  amp_security_group_name_prefix = coalesce(var.anyscale_machine_pool_security_group_name_prefix, var.common_prefix, "anyscale-machine-pool-sg-")
}

module "aws_anyscale_securitygroup_self" {
  source = "./modules/aws-anyscale-securitygroups"
  tags   = local.securitygroup_tags
  vpc_id = coalesce(var.existing_vpc_id, module.aws_anyscale_vpc.vpc_id)

  security_group_name        = local.security_group_name
  security_group_name_prefix = local.security_group_name_prefix
  # create_anyscale_public_ingress            = var.security_group_create_anyscale_public_ingress # This was for Anyscale Control Plane v1 and is no longer applicable. Commenting out before removal in a future version.
  ingress_from_cidr_map                     = local.ingress_from_cidr_range_override_defined ? var.security_group_override_ingress_from_cidr_map : local.ingress_cidr_block_defined ? local.ingress_from_cidr_map : [{}]
  ingress_with_existing_security_groups_map = local.ingress_existing_sg_defined ? var.security_group_ingress_with_existing_security_groups_map : []

  machine_pool_security_group_name        = local.amp_security_group_name
  machine_pool_security_group_name_prefix = local.amp_security_group_name_prefix
  machine_pool_cidr_ranges                = var.anyscale_machine_pool_ingress_cidr_ranges
}

# ------------------------------
# EFS Module
# ------------------------------
data "aws_subnet" "existing_subnets" {
  for_each = toset(var.existing_vpc_subnet_ids)
  id       = each.value
}
locals {
  existing_subnet_per_az_grouped = {
    for sid, sub in data.aws_subnet.existing_subnets :
    sub.availability_zone => sid...
  }
  existing_subnet_per_az = {
    for az, sids in local.existing_subnet_per_az_grouped :
    az => sids[0]
  }
  existing_subnet_unique_ids     = values(local.existing_subnet_per_az)
  existing_subnet_unique_count   = length(local.existing_subnet_unique_ids)
  efs_mount_targets_subnet_count = local.existing_subnet_unique_count > 0 ? local.existing_subnet_unique_count : max(local.anyscale_private_subnet_count, local.anyscale_public_subnet_count)
}
module "aws_anyscale_efs" {
  source         = "./modules/aws-anyscale-efs"
  tags           = local.efs_tags
  module_enabled = var.create_efs_resources

  # File system
  anyscale_efs_name  = local.efs_name
  efs_creation_token = var.efs_creation_token

  lifecycle_policy_transition_to_ia                    = var.efs_lifecycle_transition_to_ia
  lifecycle_policy_transition_to_primary_storage_class = var.efs_lifecycle_transition_to_primary_storage_class

  # Mount targets / security group
  mount_targets_subnet_count    = local.efs_mount_targets_subnet_count
  mount_targets_subnets         = coalescelist(local.existing_subnet_unique_ids, module.aws_anyscale_vpc.private_subnet_ids, module.aws_anyscale_vpc.public_subnet_ids)
  associated_security_group_ids = [module.aws_anyscale_securitygroup_self.security_group_id]

  # Encryption
  kms_key_arn = var.efs_kms_key_id

  # Backup policy
  enable_backup_policy = true
}

# ------------------------------
# MemoryDB Module
# ------------------------------
locals {
  memorydb_tags = merge(local.full_tags, var.anyscale_memorydb_tags)

  memorydb_cluster_name      = var.anyscale_memorydb_cluster_name != null ? var.anyscale_memorydb_cluster_name : local.common_name
  memorydb_cluster_name_prfx = local.memorydb_cluster_name != null ? null : coalesce(var.anyscale_memorydb_cluster_name_prefix, var.common_prefix, "anyscale-mdb-")

  memorydb_acl_name      = var.anyscale_memorydb_acl_name != null ? var.anyscale_memorydb_acl_name : local.common_name
  memorydb_acl_name_prfx = local.memorydb_acl_name != null ? null : coalesce(var.anyscale_memorydb_acl_name_prefix, var.common_prefix, "anyscale-mdb-acl-")

  memorydb_parameter_group_name      = var.anyscale_memorydb_parameter_group_name != null ? var.anyscale_memorydb_parameter_group_name : local.common_name
  memorydb_parameter_group_name_prfx = local.memorydb_parameter_group_name != null ? null : coalesce(var.anyscale_memorydb_parameter_group_name_prefix, var.common_prefix, "anyscale-mdb-pg-")
}
module "aws_anyscale_memorydb" {
  source         = "./modules/aws-anyscale-memorydb"
  tags           = local.memorydb_tags
  module_enabled = var.create_memorydb_resources #We default to false for this sub-module

  # MemoryDB
  anyscale_memorydb_name        = local.memorydb_cluster_name
  anyscale_memorydb_name_prefix = local.memorydb_cluster_name_prfx
  anyscale_memorydb_description = var.anyscale_memorydb_cluster_description
  memorydb_subnet_ids           = coalescelist(var.existing_vpc_subnet_ids, module.aws_anyscale_vpc.private_subnet_ids, module.aws_anyscale_vpc.public_subnet_ids)
  memorydb_security_group_ids   = [module.aws_anyscale_securitygroup_self.security_group_id]

  # Parameter Group
  memorydb_parameter_group_name        = local.memorydb_parameter_group_name
  memorydb_parameter_group_name_prefix = local.memorydb_parameter_group_name_prfx
  memorydb_parameter_group_description = var.anyscale_memorydb_parameter_group_description

  # ACL
  memorydb_acl_name        = local.memorydb_acl_name
  memorydb_acl_name_prefix = local.memorydb_acl_name_prfx

  # Subnet Group
  memorydb_subnet_group_name        = var.anyscale_memorydb_subnet_group_name != null ? var.anyscale_memorydb_subnet_group_name : local.common_name
  memorydb_subnet_group_name_prefix = coalesce(var.anyscale_memorydb_subnet_group_name_prefix, var.common_prefix, "anyscale-mdb-sg-")
  memorydb_subnet_group_description = var.anyscale_memorydb_subnet_group_description
}
