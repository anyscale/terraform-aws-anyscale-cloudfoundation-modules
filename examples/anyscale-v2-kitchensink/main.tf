# ---------------------------------------------------------------------------------------------------------------------
# Create core Anyscale v2 Stack with as many (non-conflicting) variables as possible.
#   Creates a v2 stack including
#     - IAM Roles
#     - S3 Bucket
#     - Private VPC
#     - VPC Security Groups
#     - EFS
#     - MemoryDB
# ---------------------------------------------------------------------------------------------------------------------
locals {
  full_tags = merge(
    var.tags
  )
}

data "aws_iam_policy_document" "custom_s3_policy" {
  statement {
    sid     = "TestCustomS3Policy2"
    actions = ["s3:GetObject"]
    effect  = "Deny"
    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}/neverdeleteme.txt"
    ]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

module "aws_anyscale_v2_kitchen_sink" {
  source        = "../../" #this should be changed if executing this example outside of this repository
  tags          = local.full_tags
  common_prefix = "anyscale-kitchensink-"

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
    "vpc_tag_test" : "kitchen_sink"
  }

  # --------------------------
  # EFS Related
  # --------------------------
  efs_lifecycle_transition_to_ia                    = ["AFTER_90_DAYS"]
  efs_lifecycle_transition_to_primary_storage_class = ["AFTER_1_ACCESS"]
  anyscale_efs_tags = {
    "efs_tag_test" : "kitchen_sink"
  }

  # --------------------------
  # S3 Related
  # --------------------------
  anyscale_s3_bucket_name = var.s3_bucket_name
  anyscale_s3_tags = {
    "s3_tag_test" : "kitchen_sink",
  }
  anyscale_s3_server_side_encryption = {
    sse_algorithm = "AES256"
  }
  anyscale_s3_force_destroy = var.anyscale_s3_force_destroy
  anyscale_s3_lifecycle_rule = [
    {
      id      = "log"
      enabled = true
      filter = {
        prefix = "log1/"
      }
      transition = [
        {
          days          = 30
          storage_class = "ONEZONE_IA"
          }, {
          days          = 60
          storage_class = "GLACIER"
        }
      ]
      noncurrent_version_transition = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
      ]
    }
  ]

  anyscale_custom_s3_policy = data.aws_iam_policy_document.custom_s3_policy.json

  # --------------------------
  # Security Group Related
  # --------------------------
  security_group_ingress_allow_access_from_cidr_range = var.customer_ingress_cidr_ranges
  security_group_enable_ssh_access                    = var.security_group_enable_ssh_access
  anyscale_securitygroup_tags = {
    "sg_tag_test" = "kitchen_sink"
  }
  security_group_name_prefix = "anyscale-kitchensink-sg-"
  # Note: security_group_override_ingress_from_cidr_map overrides the default behavior
  # including the security_group_enable_ssh_access setting
  security_group_override_ingress_from_cidr_map = [
    {
      rule        = "https-443-tcp"
      cidr_blocks = "172.24.101.0/24,172.24.102.0/24,172.24.103.0/24"
    },
    {
      rule        = "nfs-tcp"
      cidr_blocks = "172.24.0.0/16"
    },
    {
      rule        = "ssh-tcp"
      cidr_blocks = "172.24.101.0/24,172.24.102.0/24,172.24.103.0/24"
    }
  ]

  anyscale_machine_pool_ingress_cidr_ranges = ["172.24.201.0/24", "172.24.202.0/24"]

  # --------------------------
  # IAM Related
  # --------------------------
  anyscale_iam_tags = {
    "iam_tag_example" : "kitchen_sink"
  }
  anyscale_iam_cluster_node_role_name            = "anyscale-tf-cluster-node-role"
  anyscale_cluster_node_byod_secrets_policy_name = "anyscale-tf-byod-secrets-policy" #checkov:skip=CKV_SECRET_6:Secret Name is not a secret'
  anyscale_cluster_node_byod_secret_arns         = var.anyscale_cluster_node_byod_secret_arns
  anyscale_cluster_node_byod_secret_kms_arn      = var.anyscale_cluster_node_byod_secret_kms_arn

  # --------------------------
  # MemoryDB Related
  # --------------------------
  create_memorydb_resources                     = true
  anyscale_memorydb_cluster_name                = "anyscale-kitchensink-memorydb"
  anyscale_memorydb_cluster_description         = "MemoryDB for Anyscale Services"
  anyscale_memorydb_parameter_group_name_prefix = "anyscale-ks-pg-"
  anyscale_memorydb_parameter_group_description = "MemoryDB Parameter Group for Anyscale Services"
  anyscale_memorydb_subnet_group_name           = "anyscale-ks-sg"
  anyscale_memorydb_subnet_group_description    = "MemoryDB Subnet Group for Anyscale Services"
}
