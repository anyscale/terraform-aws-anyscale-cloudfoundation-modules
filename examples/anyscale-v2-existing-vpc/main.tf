# ---------------------------------------------------------------------------------------------------------------------
# Create core Anyscale v2 Stack with existing VPC (Public Subnets)
#   Creates a v2 stack including
#     - IAM Roles
#     - S3 Bucket
#       - Custom tags for the S3 bucket
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

module "aws_anyscale_v2_existing_vpc" {
  source = "../../" #this should be changed if executing this example outside of this repository
  tags   = local.full_tags

  anyscale_deploy_env = var.anyscale_deploy_env
  anyscale_cloud_id   = var.anyscale_cloud_id

  # VPC Related
  existing_vpc_id         = var.existing_vpc_id
  existing_vpc_subnet_ids = var.existing_subnet_ids

  # Security Group Related
  security_group_ingress_allow_access_from_cidr_range = var.customer_ingress_cidr_ranges

  anyscale_s3_tags = {
    "resource_tag_test" : true,
    "s3_tagging" : var.s3_tag_value
  }
}
