# ---------------------------------------------------------------------------------------------------------------------
# CREATE Anyscale AWS S3 Resources
# This template creates S3 resources for Anyscale
# ---------------------------------------------------------------------------------------------------------------------
locals {
  full_tags = merge(tomap({
    anyscale-cloud-id           = var.anyscale_cloud_id,
    anyscale-deploy-environment = var.anyscale_deploy_env
    }),
    var.tags
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# Create a VPC with no optional parameters
#   Manually specified cidr block so we don't hammer on other VPCs
#   Should be executed in us-east-2
# ---------------------------------------------------------------------------------------------------------------------
module "all_defaults" {
  source = "../.."

  cidr_block = "172.20.0.0/16"

  module_enabled = true
  tags           = local.full_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# Create the minimum VPC needed for running Anyscale
#   Manually specified cidr block so we don't hammer on other VPCs.
#   Should be executed in us-east-2
# ---------------------------------------------------------------------------------------------------------------------
module "minimum_anyscale_vpc_requirements" {
  source = "../../"

  anyscale_vpc_name = "tftest-minimum_anyscale_vpc"
  cidr_block        = "172.21.0.0/16"
  public_subnets    = ["172.21.101.0/24", "172.21.102.0/24"]

  module_enabled = true
  tags           = local.full_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# Create a VPC with public/private subnets
#   Manually specified cidr block so we don't hammer on other VPCs
#   Should be executed in us-east-2
# ---------------------------------------------------------------------------------------------------------------------
module "public_private_vpc" {
  source = "../../"

  anyscale_vpc_name = "tftest-publicprivate_anyscale_vpc"
  cidr_block        = "172.22.0.0/16"
  public_subnets    = ["172.22.101.0/24", "172.22.102.0/24"]
  private_subnets   = ["172.22.20.0/24", "172.22.21.0/24"]

  module_enabled = true
  tags           = local.full_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# Create new Subnets within an existing VPC
#   CIDR blocks do not already exist in this VPC
#   Using existing private route table - tested with both one and two route tables
#   Do not create a new VPC Endpoint and related resources
# ---------------------------------------------------------------------------------------------------------------------
module "existing_vpc_new_subnets" {
  source = "../../"

  existing_vpc_id = "vpc-086408b268f481027"

  private_subnets                  = ["10.0.20.0/24", "10.0.21.0/24"]
  existing_private_route_table_ids = ["rtb-02d75c4d4bf4c6dd1"]

  create_igw = false # We will assume this is already there
  create_ngw = false # We will assume this is already there

  gateway_vpc_endpoints = {}

  module_enabled = true
  tags           = local.full_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# Create just the Gateway Endpoints within an existing VPC and existing Subnets
#   Create a new VPC Endpoint and related resources
# ---------------------------------------------------------------------------------------------------------------------
module "existing_vpc_create_endpoints" {
  source = "../../"

  existing_vpc_id                  = "vpc-01e570eea1c7258ae"
  existing_private_route_table_ids = ["rtb-0745f6378288c2836"]

  create_igw = false # We will assume this is already there
  create_ngw = false # We will assume this is already there

  module_enabled = true
  tags           = local.full_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# Use all params and build a VPC
# ---------------------------------------------------------------------------------------------------------------------
module "kitchen_sink" {
  source = "../.."

  module_enabled = true

  anyscale_vpc_name = "tftest-kitchen_sink"
  cidr_block        = "172.23.0.0/16"

  public_subnets          = ["172.23.101.0/24", "172.23.102.0/24", "172.23.103.0/24"]
  public_subnet_names     = ["ks-pub-aza", "ks-pub-azb", "ks-pub-azc"]
  map_public_ip_on_launch = false

  private_subnets       = ["172.23.20.0/24", "172.23.21.0/24", "172.23.22.0/24"]
  private_subnet_suffix = "ks_pvt"

  availability_zones = ["us-east-2a", "us-east-2b", "us-east-2c"]

  create_ngw = true
  create_igw = true

  enable_vpc_flow_logs                            = true
  create_flow_log_cloudwatch_log_group            = true
  flow_log_cloudwatch_log_group_name_suffix       = "kitchen_sink_logs"
  flow_log_cloudwatch_log_group_retention_in_days = 7
  create_flow_log_cloudwatch_iam_role             = true

  gateway_vpc_endpoints = {
    "s3" = {
      name = "s3"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action = [
              "s3:*",
            ]
            Effect    = "Allow"
            Principal = "*"
            Resource  = "*"
          },
        ]
      })
    }
    "dynamodb" = {
      name   = "dynamodb"
      policy = null
    }
  }
  tags = local.full_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# Do not create any resources
# ---------------------------------------------------------------------------------------------------------------------
module "test_no_resources" {
  source = "../.."

  module_enabled = false
}
