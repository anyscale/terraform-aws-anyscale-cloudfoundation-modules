# ---------------------------------------------------------------------------------------------------------------------
# Create core Anyscale v2 Stack resources with minimal parameters but a common name
#   Should be executed in us-east-2
#   Creates a v2 stack including
#     - IAM Roles
#     - S3 Bucket
#     - VPC with publicly routed subnets (no private subnets)
#     - VPC Security Groups

#     - EFS is not enabled
# ---------------------------------------------------------------------------------------------------------------------
locals {
  full_tags = merge(tomap({
    anyscale-cloud-id           = var.anyscale_cloud_id,
    anyscale-deploy-environment = var.anyscale_deploy_env
    }),
    var.tags
  )
}

module "aws_anyscale_v2_common_name" {
  source = "../.." #this should be changed if executing this example outside of this repository
  tags   = local.full_tags

  anyscale_deploy_env  = var.anyscale_deploy_env
  anyscale_cloud_id    = var.anyscale_cloud_id
  anyscale_org_id      = var.anyscale_org_id
  anyscale_external_id = var.anyscale_external_id

  create_cluster_node_cloudwatch_policy = true

  # VPC Related
  anyscale_vpc_cidr_block     = "172.24.0.0/16"
  anyscale_vpc_public_subnets = ["172.24.21.0/24", "172.24.22.0/24", "172.24.23.0/24"]
  # anyscale_vpc_private_subnets = ["172.24.101.0/24", "172.24.102.0/24", "172.24.103.0/24"]

  # IAM Related
  anyscale_cluster_node_managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSQSReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]

  #checkov:skip=CKV_AWS_355:Wildcards allowed for these items
  anyscale_cluster_node_custom_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:Describe*",
        "dynamodb:List*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF

  common_prefix   = var.common_prefix
  use_common_name = true

  # Security Group Related
  security_group_ingress_allow_access_from_cidr_range = var.customer_ingress_cidr_ranges

  # EFS Resource Related
  #   Disable EFS resources to avoid creating EFS resources.
  create_efs_resources = false

  # S3 Resource Related
  anyscale_s3_force_destroy = var.anyscale_s3_force_destroy
}
