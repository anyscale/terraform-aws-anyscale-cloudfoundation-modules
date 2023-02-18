# ---------------------------------------------------------------------------------------------------------------------
# Create core Anyscale v1 Stack resources with minimal parameters
#   Should be executed in us-east-2
#   Creates a v1 stack including
#     - IAM Roles
#     - S3 Bucket
#     - VPC with publicly routed subnets (no internal)
#     - VPC Security Groups allowing public from Anyscale
#     - EFS
# ---------------------------------------------------------------------------------------------------------------------

locals {
  full_tags = merge(tomap({
    anyscale-cloud-id           = var.anyscale_cloud_id,
    anyscale-deploy-environment = var.anyscale_deploy_env
    }),
    var.tags
  )
  cidr_block     = "172.24.0.0/16"
  public_subnets = ["172.24.101.0/24", "172.24.102.0/24", "172.24.103.0/24"]
}

module "aws_anyscale_v1" {
  source = "../../"
  tags   = local.full_tags

  anyscale_deploy_env = var.anyscale_deploy_env
  anyscale_cloud_id   = var.anyscale_cloud_id

  # VPC Related
  anyscale_vpc_cidr_block     = local.cidr_block
  anyscale_vpc_public_subnets = local.public_subnets

  # Security Group Related
  security_group_create_anyscale_public_ingress       = true
  security_group_ingress_allow_access_from_cidr_range = var.customer_ingress_cidr_ranges
}

# ---------------------------------------------------------------------------------------------------------------------
# Create core Anyscale v1 Stack with existing VPC
#   Creates a v1 stack including
#     - IAM Roles
#     - S3 Bucket
#     - VPC Security Groups allowing public from Anyscale
#     - EFS
# ---------------------------------------------------------------------------------------------------------------------
locals {
  existing_vpc_id     = "vpc-086408b268f481027"
  existing_subnet_ids = ["subnet-06154a164989c0f8d", "subnet-05f678cbbba3d9a1d", "subnet-0f7b63788905e3eb2"]
}

module "aws_anyscale_v1_existing_vpc" {
  source = "../../"
  tags   = local.full_tags

  anyscale_deploy_env = var.anyscale_deploy_env
  anyscale_cloud_id   = var.anyscale_cloud_id

  # VPC Related
  existing_vpc_id         = local.existing_vpc_id
  existing_vpc_subnet_ids = local.existing_subnet_ids

  # Security Group Related
  security_group_create_anyscale_public_ingress       = true
  security_group_ingress_allow_access_from_cidr_range = var.customer_ingress_cidr_ranges

  # S3 Bucket Related
  anyscale_s3_tags = {
    "resource_tag_test" : true,
    "s3_tagging" : var.existing_vpc_s3_tag_value
  }
}
