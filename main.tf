locals {
  full_tags = merge(tomap({
    anyscale-cloud-id           = var.anyscale_cloud_id,
    anyscale-deploy-environment = var.anyscale_deploy_env
    tf_module                   = "anyscale-cloudfoundations"
    }),
    var.tags
  )
  existing_subnet_count          = length(var.existing_subnet_ids)
  anyscale_private_subnet_count  = length(var.anyscale_vpc_private_subnets)
  anyscale_public_subnet_count   = length(var.anyscale_vpc_public_subnets)
  efs_mount_targets_subnet_count = local.existing_subnet_count > 0 ? local.existing_subnet_count : local.anyscale_private_subnet_count > 0 ? local.anyscale_private_subnet_count : local.anyscale_public_subnet_count > 0 ? local.anyscale_public_subnet_count : 0

  aws_cloud_provider = var.cloud_provider == "aws" ? true : false
  create_aws_vpc     = var.existing_vpc_id == null && length(var.existing_subnet_ids) < 1 && local.aws_cloud_provider ? true : false

}

# ------------------------------
# S3 Module
# ------------------------------
module "aws_anyscale_s3" {
  source = "./modules/aws-anyscale-s3"
  tags   = local.full_tags

  anyscale_cloud_id      = var.anyscale_cloud_id
  anyscale_bucket_name   = var.anyscale_s3_bucket_name
  anyscale_bucket_prefix = var.anyscale_s3_bucket_prefix

  module_enabled = local.aws_cloud_provider
}

# ------------------------------
# IAM Module
# ------------------------------
module "aws_anyscale_iam" {
  source = "./modules/aws-anyscale-iam"
  tags   = local.full_tags

  anyscale_access_role_name              = var.anyscale_iam_access_role_name
  anyscale_access_role_name_prefix       = var.anyscale_iam_access_role_name_prefix
  anyscale_cluster_node_role_name        = var.anyscale_iam_cluster_node_role_name
  anyscale_cluster_node_role_name_prefix = var.anyscale_iam_cluster_node_role_name_prefix
  anyscale_cloud_id                      = var.anyscale_cloud_id
  anyscale_s3_bucket_arn                 = module.aws_anyscale_s3.s3_bucket_arn

  module_enabled = local.aws_cloud_provider
}

# ------------------------------
# S3 Policy Module
# ------------------------------
module "aws_anyscale_s3_policy" {
  source = "./modules/aws-anyscale-s3-policy"

  anyscale_bucket_name               = module.aws_anyscale_s3.s3_bucket_id
  anyscale_iam_access_role_arn       = module.aws_anyscale_iam.iam_anyscale_access_role_arn
  anyscale_iam_cluster_node_role_arn = module.aws_anyscale_iam.iam_cluster_node_role_arn

  module_enabled = local.aws_cloud_provider
}

# ------------------------------
# VPC (Networking) Module
# ------------------------------
module "aws_anyscale_vpc" {
  source = "./modules/aws-anyscale-vpc"
  tags   = local.full_tags

  anyscale_vpc_name = var.anyscale_vpc_name
  cidr_block        = var.anyscale_vpc_cidr_block

  public_subnets  = var.anyscale_vpc_public_subnets
  private_subnets = var.anyscale_vpc_private_subnets

  module_enabled = local.create_aws_vpc
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
  tags   = local.full_tags
  vpc_id = coalesce(var.existing_vpc_id, module.aws_anyscale_vpc.vpc_id)

  security_group_name                       = var.security_group_name
  security_group_name_prefix                = var.security_group_name_prefix
  create_anyscale_public_ingress            = var.security_group_create_anyscale_public_ingress
  ingress_from_cidr_map                     = local.ingress_from_cidr_range_override_defined ? var.security_group_override_ingress_from_cidr_map : local.ingress_cidr_block_defined ? local.ingress_from_cidr_map : [{}]
  ingress_with_existing_security_groups_map = local.ingress_existing_sg_defined ? var.security_group_ingress_with_existing_security_groups_map : []

  module_enabled = local.aws_cloud_provider
}

module "aws_anyscale_efs" {
  source = "./modules/aws-anyscale-efs"
  tags   = local.full_tags

  # File system
  anyscale_efs_name  = var.efs_name
  efs_creation_token = var.efs_creation_token

  lifecycle_policy_transition_to_ia                    = var.efs_lifecycle_transition_to_ia
  lifecycle_policy_transition_to_primary_storage_class = var.efs_lifecycle_transition_to_primary_storage_class

  # Mount targets / security group
  mount_targets_subnet_count    = local.efs_mount_targets_subnet_count
  mount_targets_subnets         = coalescelist(var.existing_subnet_ids, module.aws_anyscale_vpc.private_subnet_ids, module.aws_anyscale_vpc.public_subnet_ids)
  associated_security_group_ids = [module.aws_anyscale_securitygroup_self.security_group_id]

  # Backup policy
  enable_backup_policy = true

  module_enabled = local.aws_cloud_provider
}
