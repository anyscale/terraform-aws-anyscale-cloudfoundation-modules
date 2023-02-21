# ---------------------------------------------------------------------------------------------------------------------
# CREATE Anyscale AWS S3 Policy Resources
#   This template creates S3 Policy resources for Anyscale
#   For testing, it also creates:
#     S3 bucket
#     IAM Roles
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
# Create an S3 buckets for module testing
# ---------------------------------------------------------------------------------------------------------------------
module "s3_bucket_defaults" {
  source = "../../aws-anyscale-s3"
  tags   = local.full_tags
}

module "s3_bucket_custom_policy" {
  source = "../../aws-anyscale-s3"
  tags   = local.full_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# Create IAM Roles for module testing
# ---------------------------------------------------------------------------------------------------------------------
module "iam_roles" {
  source = "../../aws-anyscale-iam"
  tags   = local.full_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# Create an S3 bucket policy with no optional parameters
# ---------------------------------------------------------------------------------------------------------------------
module "anyscale_s3_bucket_policy" {
  source = "../"

  anyscale_bucket_name               = module.s3_bucket_defaults.s3_bucket_id
  anyscale_iam_access_role_arn       = module.iam_roles.iam_anyscale_access_role_arn
  anyscale_iam_cluster_node_role_arn = module.iam_roles.iam_cluster_node_role_arn
}

# ---------------------------------------------------------------------------------------------------------------------
# Create an S3 bucket policy using all variables
# ---------------------------------------------------------------------------------------------------------------------
module "anyscale_s3_bucket_policy_complete" {
  source                             = "../"
  anyscale_bucket_name               = module.s3_bucket_custom_policy.s3_bucket_id
  anyscale_iam_access_role_arn       = module.iam_roles.iam_anyscale_access_role_arn
  anyscale_iam_cluster_node_role_arn = module.iam_roles.iam_cluster_node_role_arn
  custom_s3_policy                   = data.aws_iam_policy_document.custom_s3_policy.json

}

data "aws_iam_policy_document" "custom_s3_policy" {
  statement {
    sid     = "TestCustomS3Policy"
    actions = ["s3:PutObject"]
    effect  = "Deny"
    resources = [
      "arn:aws:s3:::${module.s3_bucket_custom_policy.s3_bucket_id}",
      "arn:aws:s3:::${module.s3_bucket_custom_policy.s3_bucket_id}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}
