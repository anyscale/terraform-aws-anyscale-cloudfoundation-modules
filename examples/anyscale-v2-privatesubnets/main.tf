# ---------------------------------------------------------------------------------------------------------------------
# Create core Anyscale v2 Stack resources with Private VPC
#   Should be executed in us-east-2
#   Creates a v2 stack including
#     - IAM Roles
#     - S3 Bucket
#     - VPC with publicly routed subnets (no internal)
#     - VPC Security Groups
#     - EFS
#     - MemoryDB
# ---------------------------------------------------------------------------------------------------------------------
locals {
  full_tags = merge(
    var.tags
  )
}

module "aws_anyscale_v2_private_vpc" {
  source        = "../../" #this should be changed if executing this example outside of this repository
  tags          = local.full_tags
  common_prefix = "private-vpc-"

  anyscale_cloud_id    = var.anyscale_cloud_id
  anyscale_org_id      = var.anyscale_org_id
  anyscale_external_id = var.anyscale_external_id

  # --------------------------
  # VPC Related
  # --------------------------
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

  # --------------------------
  # EFS Related
  # --------------------------
  anyscale_efs_tags = {
    "efs_tag_test" : "private_vpc"
  }

  # --------------------------
  # S3 Related
  # --------------------------
  anyscale_s3_tags = {
    "s3_tag_test" : "private_vpc",
    "s3_tagging" : var.s3_tag_value
  }
  anyscale_s3_force_destroy = var.anyscale_s3_force_destroy

  # --------------------------
  # IAM Related
  # --------------------------
  anyscale_iam_tags = {
    "iam_tag_test" : "private_vpc"
  }

  # --------------------------
  # Security Group Related
  # --------------------------
  security_group_ingress_allow_access_from_cidr_range = "172.24.0.0/16" # The CIDR range of the VPC
  anyscale_securitygroup_tags = {
    "sg_tag_test" = "private_vpc"
  }

  # --------------------------
  # MemoryDB Related
  # --------------------------
  create_memorydb_resources = true
}
