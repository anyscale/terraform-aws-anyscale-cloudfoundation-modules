locals {
  full_tags = merge(tomap({
    anyscale-cloud-id           = var.anyscale_cloud_id,
    anyscale-deploy-environment = var.anyscale_deploy_env
    tf_module                   = "anyscale-cloudfoundations"
    }),
    var.tags
  )

  vpc_tags           = merge(local.full_tags, var.anyscale_vpc_tags)
  iam_tags           = merge(local.full_tags, var.anyscale_iam_tags)
  securitygroup_tags = merge(local.full_tags, var.anyscale_securitygroup_tags)
  efs_tags           = merge(local.full_tags, var.anyscale_efs_tags)
  s3_tags            = merge(local.full_tags, var.anyscale_s3_tags)

  existing_subnet_count          = length(var.existing_vpc_subnet_ids)
  anyscale_private_subnet_count  = length(var.anyscale_vpc_private_subnets)
  anyscale_public_subnet_count   = length(var.anyscale_vpc_public_subnets)
  efs_mount_targets_subnet_count = local.existing_subnet_count > 0 ? local.existing_subnet_count : local.anyscale_private_subnet_count > 0 ? local.anyscale_private_subnet_count : local.anyscale_public_subnet_count > 0 ? local.anyscale_public_subnet_count : 0

  create_new_s3_bucket = var.existing_s3_bucket_arn == null ? true : false

  create_new_vpc              = var.existing_vpc_id == null ? true : false
  create_vpc_subnets          = local.anyscale_private_subnet_count > 0 || local.anyscale_public_subnet_count > 0 ? true : false
  create_vpc_gateway_endpoint = length(var.anyscale_gateway_vpc_endpoints) > 0 && (local.create_new_vpc || length(var.existing_vpc_route_table_ids) > 0) ? true : false
  create_internet_gw          = local.create_new_vpc ? true : false
  create_nat_gw               = local.create_new_vpc ? true : false
  execute_vpc_sub_module      = local.create_new_vpc || local.create_vpc_subnets || local.create_vpc_gateway_endpoint ? true : false

  s3_bucket_prefix                  = coalesce(var.anyscale_s3_bucket_prefix, var.general_prefix, "anyscale-")
  iam_access_role_name_prefix       = coalesce(var.anyscale_iam_access_role_name_prefix, var.general_prefix, "anyscale-iam-role-")
  iam_cluster_node_role_name_prefix = coalesce(var.anyscale_iam_cluster_node_role_name_prefix, var.general_prefix, "anyscale-cluster-node-")
  security_group_name_prefix        = coalesce(var.security_group_name_prefix, var.general_prefix, "anyscale-security-group-")
  steadystate_policy_prefix         = coalesce(var.anyscale_access_steadystate_policy_prefix, var.general_prefix, "anyscale-steady_state-")

}

# ------------------------------
# S3 Module
# ------------------------------
module "aws_anyscale_s3" {
  source = "./modules/aws-anyscale-s3"
  tags   = local.s3_tags

  anyscale_cloud_id      = var.anyscale_cloud_id
  anyscale_bucket_name   = var.anyscale_s3_bucket_name
  anyscale_bucket_prefix = local.s3_bucket_prefix
  server_side_encryption = var.anyscale_s3_server_side_encryption
  force_destroy          = var.anyscale_s3_force_destroy

  module_enabled = local.create_new_s3_bucket
}

# ------------------------------
# IAM Module
# ------------------------------
module "aws_anyscale_iam" {
  source = "./modules/aws-anyscale-iam"
  tags   = local.iam_tags

  anyscale_access_role_name              = var.anyscale_iam_access_role_name
  anyscale_access_role_name_prefix       = local.iam_access_role_name_prefix
  anyscale_cluster_node_role_name        = var.anyscale_iam_cluster_node_role_name
  anyscale_cluster_node_role_name_prefix = local.iam_cluster_node_role_name_prefix

  anyscale_access_steadystate_policy_name   = var.anyscale_access_steadystate_policy_name
  anyscale_access_steadystate_policy_prefix = local.steadystate_policy_prefix

  anyscale_cloud_id = var.anyscale_cloud_id

  anyscale_s3_bucket_arn = local.create_new_s3_bucket ? module.aws_anyscale_s3.s3_bucket_arn : var.existing_s3_bucket_arn
}

# ------------------------------
# S3 Policy Module
# ------------------------------
module "aws_anyscale_s3_policy" {
  source = "./modules/aws-anyscale-s3-policy"

  anyscale_bucket_name               = module.aws_anyscale_s3.s3_bucket_id
  anyscale_iam_access_role_arn       = module.aws_anyscale_iam.iam_anyscale_access_role_arn
  anyscale_iam_cluster_node_role_arn = module.aws_anyscale_iam.iam_cluster_node_role_arn

  custom_s3_policy = var.anyscale_custom_s3_policy

  module_enabled = local.create_new_s3_bucket
}

# ------------------------------
# VPC (Networking) Module
# ------------------------------
module "aws_anyscale_vpc" {
  source = "./modules/aws-anyscale-vpc"
  tags   = local.vpc_tags

  anyscale_vpc_name = var.anyscale_vpc_name
  cidr_block        = var.anyscale_vpc_cidr_block

  public_subnets  = var.anyscale_vpc_public_subnets
  private_subnets = var.anyscale_vpc_private_subnets

  create_igw = local.create_internet_gw
  create_ngw = local.create_nat_gw

  gateway_vpc_endpoints = var.anyscale_gateway_vpc_endpoints

  existing_vpc_id             = var.existing_vpc_id
  existing_private_subnet_ids = var.existing_vpc_subnet_ids
  existing_route_table_ids    = var.existing_vpc_route_table_ids

  module_enabled = local.execute_vpc_sub_module
}

# ------------------------------
# Security Group Module
# ------------------------------
locals {
  ingress_cidr_block_defined = length(var.security_group_ingress_allow_access_from_cidr_range) > 1 ? true : false
  ingress_from_cidr_map = [
    {
      rule        = "https-443-tcp"
      cidr_blocks = var.security_group_ingress_allow_access_from_cidr_range
    },
    {
      rule        = "ssh-tcp"
      cidr_blocks = var.security_group_ingress_allow_access_from_cidr_range
    }
  ]
  ingress_from_cidr_range_override_defined = length(var.security_group_override_ingress_from_cidr_map) > 1 ? true : false

  ingress_existing_sg_defined = length(var.security_group_ingress_with_existing_security_groups_map) > 1 ? true : false
}

module "aws_anyscale_securitygroup_self" {
  source = "./modules/aws-anyscale-securitygroups"
  tags   = local.securitygroup_tags
  vpc_id = coalesce(var.existing_vpc_id, module.aws_anyscale_vpc.vpc_id)

  security_group_name                       = var.security_group_name
  security_group_name_prefix                = local.security_group_name_prefix
  create_anyscale_public_ingress            = var.security_group_create_anyscale_public_ingress
  ingress_from_cidr_map                     = local.ingress_from_cidr_range_override_defined ? var.security_group_override_ingress_from_cidr_map : local.ingress_cidr_block_defined ? local.ingress_from_cidr_map : [{}]
  ingress_with_existing_security_groups_map = local.ingress_existing_sg_defined ? var.security_group_ingress_with_existing_security_groups_map : []
}

module "aws_anyscale_efs" {
  source = "./modules/aws-anyscale-efs"
  tags   = local.efs_tags

  # File system
  anyscale_efs_name  = var.efs_name
  efs_creation_token = var.efs_creation_token

  lifecycle_policy_transition_to_ia                    = var.efs_lifecycle_transition_to_ia
  lifecycle_policy_transition_to_primary_storage_class = var.efs_lifecycle_transition_to_primary_storage_class

  # Mount targets / security group
  mount_targets_subnet_count    = local.efs_mount_targets_subnet_count
  mount_targets_subnets         = coalescelist(var.existing_vpc_subnet_ids, module.aws_anyscale_vpc.private_subnet_ids, module.aws_anyscale_vpc.public_subnet_ids)
  associated_security_group_ids = [module.aws_anyscale_securitygroup_self.security_group_id]

  # Backup policy
  enable_backup_policy = true
}
