# ---------------------------------------------------------------------------------------------------------------------
# Create core Anyscale v2 Stack resources with minimal parameters
#   Should be executed in us-east-2
#   Creates a v2 stack including
#     - IAM Roles
#     - S3 Bucket
#     - VPC with publicly routed subnets (no private subnets)
#     - VPC Security Groups
#     - EFS
# ---------------------------------------------------------------------------------------------------------------------

locals {
  full_tags = merge(tomap({
    anyscale-cloud-id           = var.anyscale_cloud_id,
    anyscale-deploy-environment = var.anyscale_deploy_env
    }),
    var.tags
  )
  minimal_param_cidr_block     = "172.24.0.0/16"
  minimal_param_public_subnets = ["172.24.101.0/24", "172.24.102.0/24", "172.24.103.0/24"]
}

module "aws_anyscale_v2" {
  source = "../.."
  tags   = local.full_tags

  anyscale_deploy_env = var.anyscale_deploy_env
  anyscale_cloud_id   = var.anyscale_cloud_id

  # VPC Related
  anyscale_vpc_cidr_block     = local.minimal_param_cidr_block
  anyscale_vpc_public_subnets = local.minimal_param_public_subnets

  # Security Group Related
  security_group_ingress_allow_access_from_cidr_range = var.customer_ingress_cidr_ranges
}

# ---------------------------------------------------------------------------------------------------------------------
# Create core Anyscale v2 Stack with existing VPC (Public Subnets)
#   Creates a v2 stack including
#     - IAM Roles
#     - S3 Bucket
#     - VPC Security Groups
#     - EFS
# ---------------------------------------------------------------------------------------------------------------------
locals {
  existing_vpc_id            = "vpc-086408b268f481027"
  existing_public_subnet_ids = ["subnet-06154a164989c0f8d", "subnet-05f678cbbba3d9a1d", "subnet-0f7b63788905e3eb2"]
}

module "aws_anyscale_v2_existing_vpc" {
  source = "../../"
  tags   = local.full_tags

  anyscale_deploy_env = var.anyscale_deploy_env
  anyscale_cloud_id   = var.anyscale_cloud_id

  # VPC Related
  existing_vpc_id         = local.existing_vpc_id
  existing_vpc_subnet_ids = local.existing_public_subnet_ids

  # Security Group Related
  security_group_ingress_allow_access_from_cidr_range = var.customer_ingress_cidr_ranges
}

# ---------------------------------------------------------------------------------------------------------------------
# Create core Anyscale v2 Stack resources with Private VPC
#   Should be executed in us-east-2
#   Creates a v2 stack including
#     - IAM Roles
#     - S3 Bucket
#     - VPC with publicly routed subnets (no internal)
#     - VPC Security Groups
#     - EFS
# ---------------------------------------------------------------------------------------------------------------------
locals {
  private_vpc_cidr_block      = "172.24.0.0/16"
  private_vpc_public_subnets  = ["172.24.21.0/24", "172.24.22.0/24", "172.24.23.0/24"]
  private_vpc_private_subnets = ["172.24.101.0/24", "172.24.102.0/24", "172.24.103.0/24"]
}

module "aws_anyscale_v2_private_vpc" {
  source        = "../../"
  tags          = local.full_tags
  common_prefix = "private-vpc-"

  anyscale_deploy_env = var.anyscale_deploy_env
  anyscale_cloud_id   = var.anyscale_cloud_id

  # VPC Related
  anyscale_vpc_cidr_block      = local.private_vpc_cidr_block
  anyscale_vpc_public_subnets  = local.private_vpc_public_subnets
  anyscale_vpc_private_subnets = local.private_vpc_private_subnets
  anyscale_vpc_tags = {
    "vpc_tag_test" : "private_vpc"
  }

  # EFS Related
  anyscale_efs_tags = {
    "efs_tag_test" : "private_vpc"
  }
  # S3 Related
  anyscale_s3_tags = {
    "s3_tag_test" : "private_vpc"
  }

  # IAM Related
  anyscale_iam_tags = {
    "iam_tag_test" : "private_vpc"
  }

  # Security Group Related
  security_group_ingress_allow_access_from_cidr_range = "172.24.0.0/16"
  anyscale_securitygroup_tags = {
    "sg_tag_test" = "private_vpc"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Create core Anyscale v2 Stack resources with minimal parameters but a common name
#   Should be executed in us-east-2
#   Creates a v2 stack including
#     - IAM Roles
#     - S3 Bucket
#     - VPC with publicly routed subnets (no private subnets)
#     - VPC Security Groups
#     - EFS
# ---------------------------------------------------------------------------------------------------------------------

locals {
  common_name_cidr_block      = "172.24.0.0/16"
  common_name_public_subnets  = ["172.24.21.0/24", "172.24.22.0/24", "172.24.23.0/24"]
  common_name_private_subnets = ["172.24.101.0/24", "172.24.102.0/24", "172.24.103.0/24"]
}

module "aws_anyscale_v2_common_name" {
  source = "../.."
  tags   = local.full_tags

  anyscale_deploy_env = var.anyscale_deploy_env
  anyscale_cloud_id   = var.anyscale_cloud_id

  # VPC Related
  anyscale_vpc_cidr_block      = local.common_name_cidr_block
  anyscale_vpc_public_subnets  = local.common_name_public_subnets
  anyscale_vpc_private_subnets = local.common_name_private_subnets

  common_prefix   = "brent-pfx-test-"
  use_common_name = true

  # Security Group Related
  security_group_ingress_allow_access_from_cidr_range = var.customer_ingress_cidr_ranges
}

# ---------------------------------------------------------------------------------------------------------------------
# Create core Anyscale v2 Stack with existing VPC and S3 Bucket
#   Creates a v2 stack including
#     - IAM Roles
#     - VPC Security Groups
#     - EFS
#     - VPC Gateway Endpoint for S3 (not needed in this VPC but for testing purposes)
# ---------------------------------------------------------------------------------------------------------------------

# module "aws_anyscale_v2_existing_vpc_existing_s3" {
#   source = "../../"
#   tags   = local.full_tags

#   anyscale_deploy_env = var.anyscale_deploy_env
#   anyscale_cloud_id   = var.anyscale_cloud_id

#   # VPC Related
#   existing_vpc_id         = local.existing_vpc_id
#   existing_vpc_subnet_ids = local.existing_subnet_ids

#   # Security Group Related
#   security_group_ingress_allow_access_from_cidr_range = var.customer_ingress_cidr_ranges
# }
