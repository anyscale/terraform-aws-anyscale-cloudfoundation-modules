# ---------------------------------------------------------------------------------------------------------------------
# CREATE Anyscale AWS Security Group Resources
# This template creates Secrutiy Group resources for Anyscale
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
# Create a VPC (required for testing security groups)
# ---------------------------------------------------------------------------------------------------------------------
locals {
  public_subnets = ["172.24.101.0/24", "172.24.102.0/24", "172.24.103.0/24"]
}
module "security_groups_tftest_vpc" {
  source = "../../../aws-anyscale-vpc"

  anyscale_vpc_name = "tftest-securitygroups"
  cidr_block        = "172.24.0.0/16"

  public_subnets = local.public_subnets
}

# ---------------------------------------------------------------------------------------------------------------------
# Create a Security Group resource with no optional parameters
# ---------------------------------------------------------------------------------------------------------------------
module "all_defaults" {
  source         = "../.."
  module_enabled = true

  vpc_id = module.security_groups_tftest_vpc.vpc_id

  ingress_from_cidr_map = [
    {
      rule        = "https-443-tcp"
      cidr_blocks = var.ingress_cidr_block
    }
  ]

  tags = local.full_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# Create a Security Group resource with Machine Pool defaults
#  Specifying name_prefix as well for ease of finding resource in console.
# ---------------------------------------------------------------------------------------------------------------------
module "anyscale_amp" {
  source         = "../.."
  module_enabled = true

  vpc_id = module.security_groups_tftest_vpc.vpc_id

  security_group_name_prefix = "anyscale-tftest-amp-"

  machine_pool_security_group_name_prefix = "anyscale-tftest-amp-sg-"
  machine_pool_cidr_ranges                = ["10.100.20.0/24"]

  tags = local.full_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# Use all params and build a Security Group
# ---------------------------------------------------------------------------------------------------------------------
module "kitchen_sink" {
  source         = "../.."
  module_enabled = true

  vpc_id = module.security_groups_tftest_vpc.vpc_id

  security_group_name        = "anyscale-tftest-kitchensink-securitygroup"
  security_group_description = "Anyscale tf test security group"

  default_ingress_cidr_range = ["10.100.10.11/32"]
  ingress_from_cidr_map = [
    {
      rule        = "https-443-tcp"
      cidr_blocks = "10.100.10.10/32"
    },
    {
      rule        = "http-80-tcp"
      cidr_blocks = "10.100.10.10/32"
    },
    {
      rule = "nfs-tcp"
    },
    {
      from_port   = 10
      to_port     = 20
      protocol    = 6
      description = "Service name is TEST"
      cidr_blocks = "10.100.10.10/32"
    }
  ]

  ingress_with_existing_security_groups_map = [
    {
      rule              = "https-443-tcp"
      security_group_id = module.anyscale_amp.security_group_id
    }
  ]

  ingress_with_self = [
    { rule = "http-80-tcp" },
    { rule = "ssh-tcp" }
  ]

  egress_to_self = [
    { rule = "ssh-tcp" },
    { rule = "https-443-tcp" }
  ]

  egress_to_cidr_map = [
    {
      rule        = "https-443-tcp"
      cidr_blocks = "10.100.10.10/32"
    },
  ]

  machine_pool_security_group_name = "anyscale-tftest-kitchensink-machinepool-sg"
  # machine_pool_cidr_ranges         = ["10.100.20.0/24", "10.100.21.0/24", "10.100.22.0/24"] # 3 CIDR ranges
  machine_pool_cidr_ranges = ["10.100.20.0/24", "10.100.21.0/24"] # 2 CIDR ranges

  tags = local.full_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# Do not create any resources
# ---------------------------------------------------------------------------------------------------------------------
module "test_no_resources" {
  source         = "../.."
  module_enabled = false

  vpc_id = module.security_groups_tftest_vpc.vpc_id

}
