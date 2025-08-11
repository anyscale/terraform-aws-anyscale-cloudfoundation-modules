# ---------------------------------------------------------------------------------------------------------------------
# CREATE Anyscale AWS EFS Resources
#   This template creates EFS resources for Anyscale
#   Requires a VPC
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # azs = slice(data.aws_availability_zones.available.names, 0, 3)

  full_tags = merge(tomap({
    anyscale-cloud-id           = var.anyscale_cloud_id,
    anyscale-deploy-environment = var.anyscale_deploy_env
    }),
    var.tags
  )
}

# data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}

# ---------------------------------------------------------------------------------------------------------------------
# Create an EFS Resource with no optional parameters
#   Should be executed in us-east-2
# ---------------------------------------------------------------------------------------------------------------------
module "all_defaults" {
  source = "../"

  tags = local.full_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# Use all params and build an EFS Resource
#   Also creates a VPC resource
# ---------------------------------------------------------------------------------------------------------------------
locals {
  public_subnets  = ["172.24.101.0/24", "172.24.102.0/24", "172.24.103.0/24"]
  private_subnets = ["172.24.20.0/24", "172.24.21.0/24", "172.24.22.0/24"]
}
module "efs_vpc" {
  source = "../../aws-anyscale-vpc"

  anyscale_vpc_name = "tftest-efs"
  cidr_block        = "172.24.0.0/16"

  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets
}

module "efs_securitygroups" {
  source = "../../aws-anyscale-securitygroups"

  vpc_id = module.efs_vpc.vpc_id

  security_group_name_prefix = "anyscale-tftest-efs-"

  ingress_with_self = [
    { rule = "all-all" }
  ]
}
locals {
  # Because subnet ID may not be known at plan time, we cannot use it as a key
  mount_targets_subnet_count = length(local.private_subnets)
}

module "kitchen_sink" {
  source = "../"

  # File system
  anyscale_efs_name  = "tftest-kitchen_sink"
  efs_creation_token = "tftest-kitchen_sink" #checkov:skip=CKV_SECRET_6:This is not a secret
  efs_encrypted      = true
  tags               = local.full_tags

  efs_performance_mode            = "maxIO"
  efs_throughput_mode             = "provisioned"
  provisioned_throughput_in_mibps = 256

  lifecycle_policy_transition_to_ia                    = ["AFTER_7_DAYS"]
  lifecycle_policy_transition_to_primary_storage_class = []

  # File system policy
  attach_policy                      = true
  bypass_policy_lockout_safety_check = true
  policy_statements = [
    {
      sid     = "Example"
      actions = ["elasticfilesystem:ClientMount"]
      principals = [
        {
          type        = "AWS"
          identifiers = [data.aws_caller_identity.current.arn]
        }
      ]
    }
  ]

  # Mount targets / security group
  mount_targets_subnet_count    = local.mount_targets_subnet_count
  mount_targets_subnets         = module.efs_vpc.private_subnet_ids
  associated_security_group_ids = [module.efs_securitygroups.security_group_id]

  # Access point(s)
  access_points = {
    posix_test = {
      name = "posix-test"
      posix_user = {
        gid            = 1001
        uid            = 1001
        secondary_gids = [1002]
      }

      tags = {
        Additionl = "yes"
      }
    }
    root_test = {
      root_directory = {
        path = "/example"
        creation_info = {
          owner_gid   = 1001
          owner_uid   = 1001
          permissions = "755"
        }
      }
    }
  }

  # Backup policy
  enable_backup_policy = true

  # # Replication configuration
  # create_replication_configuration = true
  # replication_configuration_destination = {
  #   availability_zone_name = "us-east-1a"
  # }
}

# ---------------------------------------------------------------------------------------------------------------------
# Do not create any resources
# ---------------------------------------------------------------------------------------------------------------------
module "test_no_resources" {
  source = "../"

  module_enabled = false
}
