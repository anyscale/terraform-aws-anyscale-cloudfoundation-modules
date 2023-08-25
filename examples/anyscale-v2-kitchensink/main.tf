# ---------------------------------------------------------------------------------------------------------------------
# Create core Anyscale v2 Stack with as many (non-conflicting) variables as possible.
#   Creates a v2 stack including
#     - IAM Roles
#     - S3 Bucket
#     - Private VPC
#     - EFS
# ---------------------------------------------------------------------------------------------------------------------
locals {
  full_tags = merge(tomap({
    anyscale-cloud-id = var.anyscale_cloud_id
    }),
    var.tags
  )
}

module "aws_anyscale_v2_kitchen_sink" {
  source        = "../../" #this should be changed if executing this example outside of this repository
  tags          = local.full_tags
  common_prefix = "anyscale-kitchensink-"

  anyscale_cloud_id = var.anyscale_cloud_id

  #--------------
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
    "vpc_tag_test" : "kitchen_sink"
  }

  #--------------
  # EFS Related
  efs_lifecycle_transition_to_ia                    = ["AFTER_90_DAYS"]
  efs_lifecycle_transition_to_primary_storage_class = ["AFTER_1_ACCESS"]
  anyscale_efs_tags = {
    "efs_tag_test" : "kitchen_sink"
  }

  #--------------
  # S3 Related
  anyscale_s3_bucket_name = "anyscale-kitchensink-s3"
  anyscale_s3_tags = {
    "s3_tag_test" : "kitchen_sink",
  }
  anyscale_s3_server_side_encryption = {
    sse_algorithm = "AES256"
  }
  anyscale_s3_force_destroy = true
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

  #--------------------------
  # Security Group Related
  security_group_ingress_allow_access_from_cidr_range = var.customer_ingress_cidr_ranges
  anyscale_securitygroup_tags = {
    "sg_tag_test" = "kitchen_sink"
  }
  security_group_name_prefix = "anyscale-kitchensink-sg-"
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

  #--------------
  # IAM Related
  anyscale_iam_tags = {
    "iam_tag_example" : "kitchen_sink"
  }
  anyscale_iam_cluster_node_role_name            = "anyscale-tf-cluster-node-role"
  anyscale_cluster_node_byod_secrets_policy_name = "anyscale-tf-byod-secrets-policy" #checkov:skip=CKV_SECRET_6:Secret Name is not a secret'
  anyscale_cluster_node_byod_secret_arns         = var.anyscale_cluster_node_byod_secret_arns
  anyscale_cluster_node_byod_secret_kms_arn      = var.anyscale_cluster_node_byod_secret_kms_arn
}
