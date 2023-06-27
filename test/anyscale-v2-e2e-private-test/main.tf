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
  full_tags = merge(tomap({
    anyscale-cloud-id           = var.anyscale_cloud_id,
    anyscale-deploy-environment = var.anyscale_deploy_env
    }),
    var.tags
  )
}

module "aws_anyscale_v2_private_vpc" {
  source = "../../"
  tags   = local.full_tags

  common_prefix   = var.common_prefix
  use_common_name = true

  anyscale_deploy_env = var.anyscale_deploy_env
  anyscale_cloud_id   = var.anyscale_cloud_id

  # VPC Related
  anyscale_vpc_cidr_block     = "172.24.0.0/16"
  anyscale_vpc_public_subnets = ["172.24.21.0/24", "172.24.22.0/24", "172.24.23.0/24"]
  anyscale_vpc_public_subnet_tags = tomap({
    public_subnet = "true",
    tgw_attach    = "false"
  })
  anyscale_vpc_private_subnets = ["172.24.101.0/24", "172.24.102.0/24", "172.24.103.0/24"]
  anyscale_vpc_private_subnet_tags = tomap({
    public_subnet = "false",
    tgw_attach    = "false"
  })
  anyscale_vpc_tags = {
    "vpc_tag_test" : "private_vpc"
  }

  # EFS Related
  anyscale_efs_tags = {
    "efs_tag_test" : "private_vpc"
  }
  # S3 Related
  anyscale_s3_tags = {
    "s3_tag_test" : "private_vpc",
    "s3_tagging" : var.s3_tag_value
  }

  # IAM Related
  anyscale_iam_tags = {
    "iam_tag_test" : "private_vpc"
  }
  anyscale_access_role_trusted_role_arns = var.anyscale_access_role_trusted_role_arns

  # Security Group Related
  security_group_ingress_allow_access_from_cidr_range = "172.24.0.0/16"
  anyscale_securitygroup_tags = {
    "sg_tag_test" = "private_vpc"
  }
}
