# ---------------------------------------------------------------------------------------------------------------------
# Create core Anyscale v2 Stack resources with minimal parameters but use an existing S3 Bucket
#   Should be executed in us-east-2
#   Creates a v2 stack including
#     - IAM Roles
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
}

module "aws_anyscale_v2_existing_s3" {
  source = "../.." #this should be changed if executing this example outside of this repository
  tags   = local.full_tags

  anyscale_deploy_env = var.anyscale_deploy_env
  anyscale_cloud_id   = var.anyscale_cloud_id
  anyscale_org_id     = var.anyscale_org_id

  create_cluster_node_cloudwatch_policy = true

  existing_s3_bucket_arn = var.existing_s3_bucket_arn

  # VPC Related
  anyscale_vpc_cidr_block     = "172.24.0.0/16"
  anyscale_vpc_public_subnets = ["172.24.21.0/24", "172.24.22.0/24", "172.24.23.0/24"]
  # anyscale_vpc_private_subnets = ["172.24.101.0/24", "172.24.102.0/24", "172.24.103.0/24"]

  common_prefix   = var.common_prefix
  use_common_name = true

  # Security Group Related
  security_group_ingress_allow_access_from_cidr_range = var.customer_ingress_cidr_ranges


}
