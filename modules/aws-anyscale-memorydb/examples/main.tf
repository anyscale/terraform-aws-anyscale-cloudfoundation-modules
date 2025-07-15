# ---------------------------------------------------------------------------------------------------------------------
# CREATE Anyscale AWS MemoryDB Resources
#   This template creates MemoryDB resources for Anyscale
#   Also creates VPCs and Security Groups
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

# ---------------------------------------------------------------------------------------------------------------------
# Use default params and build a MemoryDB Resource.
#   Also creates a VPC resource
# ---------------------------------------------------------------------------------------------------------------------
locals {
  all_defaults_public_subnets = ["172.24.101.0/24", "172.24.102.0/24", "172.24.103.0/24"]
}
module "all_defaults_vpc" {
  source = "../../aws-anyscale-vpc"

  anyscale_vpc_name = "tftest-memorydb"
  cidr_block        = "172.24.0.0/16"

  public_subnets = local.all_defaults_public_subnets
}

module "all_defaults_securitygroups" {
  source = "../../aws-anyscale-securitygroups"

  vpc_id = module.all_defaults_vpc.vpc_id

  security_group_name_prefix = "anyscale-tftest-memorydb-"

  ingress_with_self = [
    { rule = "all-all" }
  ]
}

module "all_defaults" {
  source         = "../"
  module_enabled = true

  # MemoryDB
  tags = local.full_tags

  memorydb_subnet_ids         = module.all_defaults_vpc.public_subnet_ids
  memorydb_security_group_ids = [module.all_defaults_securitygroups.security_group_id]
}

# ---------------------------------------------------------------------------------------------------------------------
# Use all params and build a MemoryDB Resource.
#   Also creates a VPC resource
# ---------------------------------------------------------------------------------------------------------------------
locals {
  kitchensink_public_subnets  = ["172.24.101.0/24", "172.24.102.0/24", "172.24.103.0/24"]
  kitchensink_private_subnets = ["172.24.20.0/24", "172.24.21.0/24", "172.24.22.0/24"]
}
module "kitchensink_vpc" {
  source = "../../aws-anyscale-vpc"

  anyscale_vpc_name = "tftest-memorydb"
  cidr_block        = "172.24.0.0/16"

  public_subnets  = local.kitchensink_public_subnets
  private_subnets = local.kitchensink_private_subnets
}

module "kitchensink_securitygroups" {
  source = "../../aws-anyscale-securitygroups"

  vpc_id = module.kitchensink_vpc.vpc_id

  security_group_name_prefix = "anyscale-tftest-memorydb-"

  ingress_with_self = [
    { rule = "all-all" }
  ]
}

resource "random_password" "password" {
  for_each = toset(["admin", "readonly"])

  length           = 16
  special          = true
  override_special = "_%@"
}

module "kitchen_sink" {
  source         = "../"
  module_enabled = true

  # MemoryDB
  anyscale_memorydb_name = "tftest-kitchensink"
  tags                   = local.full_tags

  memorydb_security_group_ids = [module.kitchensink_securitygroups.security_group_id]

  # memorydb_kms_key_arn              = "arn:aws:kms:us-east-2:${data.aws_caller_identity.current.account_id}:key/12345678-1234-1234-1234-123456789012"
  anyscale_memorydb_description     = "This is a test description"
  enable_auto_minor_version_upgrade = true

  memorydb_node_type          = "db.r6gd.xlarge"
  memorydb_port               = "6380"
  memorydb_maintenance_window = "tue:01:00-tue:02:00"

  memorydb_num_shards             = 4
  memorydb_num_replicas_per_shard = 3
  enable_memorydb_data_tiering    = true

  memorydb_tls_enabled              = true
  memorydb_snapshot_retention_limit = 14
  memorydb_snapshot_window          = "04:00-05:00"
  memorydb_final_snapshot_name      = "tftest-kitchensink-final-snapshot"

  # MemoryDB Parameter Group
  create_memorydb_parameter_group      = true
  memorydb_parameter_group_name        = "tftest-kitchensink"
  memorydb_parameter_group_description = "This is a test description"
  memorydb_parameter_group_family      = "memorydb_redis7"

  memorydb_parameter_group_parameters = [
    {
      name  = "maxmemory-policy"
      value = "allkeys-lru"
    },
    {
      name  = "notify-keyspace-events"
      value = "lK"
    }
  ]
  memorydb_parameter_group_tags = {
    "parameter_group_test" = "kitchen_sink"
  }

  # MemoryDB ACL
  create_memorydb_acl = true
  memorydb_acl_name   = "tftest-kitchensink-acl"

  memorydb_acl_user_names = [
    "admin-user",
    "readonly-user"
  ]

  memorydb_acl_tags = {
    "acl_test" = "kitchen_sink"
  }

  # MemoryDB Users
  create_memorydb_users = true
  memorydb_users = {
    admin = {
      user_name     = "admin-user"
      access_string = "on ~* &* +@all"
      passwords     = [random_password.password["admin"].result]
      tags          = { user = "admin" }
    }
    readonly = {
      user_name     = "readonly-user"
      access_string = "on ~* &* -@all +@read"
      passwords     = [random_password.password["readonly"].result]
      tags          = { user = "readonly" }
    }
  }

  # MemoryDB Subnet Group
  create_memorydb_subnet_group      = true
  memorydb_subnet_group_name_prefix = "tftest-kitchensink-"
  memorydb_subnet_group_description = "This is a test description"

  memorydb_subnet_ids = module.kitchensink_vpc.private_subnet_ids

  memorydb_subnet_group_tags = {
    "subnet_group_test" = "kitchen_sink"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Do not create any resources
# ---------------------------------------------------------------------------------------------------------------------
module "test_no_resources" {
  source         = "../"
  module_enabled = false

  memorydb_subnet_ids         = []
  memorydb_security_group_ids = []
}
