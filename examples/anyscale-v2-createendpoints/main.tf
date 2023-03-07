# ---------------------------------------------------------------------------------------------------------------------
# Create core Anyscale v2 Stack with existing VPC (Public Subnets)
#   Creates a v2 stack including
#     - IAM Roles
#     - S3 Bucket
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

module "aws_anyscale_v2_createendpoints" {
  source = "../../"
  tags   = local.full_tags

  anyscale_deploy_env = var.anyscale_deploy_env
  anyscale_cloud_id   = var.anyscale_cloud_id

  # VPC Related
  existing_vpc_id                      = "vpc-07ae27a170d7fc7be"
  existing_vpc_subnet_ids              = ["subnet-0d3c9339dd7b4419e", "subnet-065bf13bbea271c3c"]
  existing_vpc_private_route_table_ids = ["rtb-06c6a1cfd89cb8e96", "rtb-0668cedc29747917f"]
  # existing_vpc_public_route_table_ids  = ["rtb-00b074124e7d41fd3"]
  anyscale_gateway_vpc_endpoints = {
    "s3" = {
      name   = "s3"
      policy = null
    }
  }

  # Security Group Related
  security_group_ingress_allow_access_from_cidr_range = var.customer_ingress_cidr_ranges
}
