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
# Use default params and build a Resource.
#   Also creates a S3 Bucket and IAM Resources
# ---------------------------------------------------------------------------------------------------------------------

module "s3_bucket_all_defaults" {
  source = "../../aws-anyscale-s3"

  anyscale_bucket_name = "anyscale-tf-test-all-defaults"
  tags                 = local.full_tags
}

module "iam_roles_all_defaults" {
  source = "../../aws-anyscale-iam"

  create_iam_s3_policy   = true
  anyscale_s3_bucket_arn = module.s3_bucket_all_defaults.s3_bucket_arn

  tags = local.full_tags
}

module "all_defaults" {
  source = "../"

  anyscale_bucket_name           = module.s3_bucket_all_defaults.s3_bucket_id
  anyscale_controlplane_role_arn = module.iam_roles_all_defaults.iam_anyscale_access_role_arn
  anyscale_dataplane_role_arn    = module.iam_roles_all_defaults.iam_cluster_node_role_arn
}

# ---------------------------------------------------------------------------------------------------------------------
# Create an S3 bucket policy with a custom JSON policy
# ---------------------------------------------------------------------------------------------------------------------
module "s3_bucket_kitchen_sink" {
  source = "../../aws-anyscale-s3"

  anyscale_bucket_name = "anyscale-tf-test-kitchen-sink"

  tags = local.full_tags
}


module "iam_roles_kitchen_sink" {
  source = "../../aws-anyscale-iam"

  create_iam_s3_policy   = true
  anyscale_s3_bucket_arn = module.s3_bucket_kitchen_sink.s3_bucket_arn

  tags = local.full_tags
}

data "aws_iam_policy_document" "custom_s3_policy" {
  statement {
    sid     = "TestCustomS3Policy"
    actions = ["s3:PutObject"]
    effect  = "Allow"
    resources = [
      "arn:aws:s3:::${module.s3_bucket_kitchen_sink.s3_bucket_id}",
      "arn:aws:s3:::${module.s3_bucket_kitchen_sink.s3_bucket_id}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }

  statement {
    sid     = "TestCustomS3Policy2"
    actions = ["s3:GetObject"]
    effect  = "Deny"
    resources = [
      "arn:aws:s3:::${module.s3_bucket_kitchen_sink.s3_bucket_id}/neverdeleteme.txt"
    ]
    principals {
      type        = "AWS"
      identifiers = [module.iam_roles_kitchen_sink.iam_anyscale_access_role_arn]
    }
  }
}

module "kitchen_sink" {
  source                         = "../"
  anyscale_bucket_name           = module.s3_bucket_kitchen_sink.s3_bucket_id
  anyscale_controlplane_role_arn = module.iam_roles_kitchen_sink.iam_anyscale_access_role_arn
  anyscale_dataplane_role_arn    = module.iam_roles_kitchen_sink.iam_cluster_node_role_arn
  custom_s3_policy               = data.aws_iam_policy_document.custom_s3_policy.json
}


# ---------------------------------------------------------------------------------------------------------------------
# Do not create any resources
# ---------------------------------------------------------------------------------------------------------------------
module "test_no_resources" {
  source = "../"

  module_enabled                 = false
  anyscale_bucket_name           = "none"
  anyscale_controlplane_role_arn = "none"
  anyscale_dataplane_role_arn    = "none"
}
