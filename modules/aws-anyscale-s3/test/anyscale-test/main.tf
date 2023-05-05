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
# Create an S3 bucket with no optional parameters
# ---------------------------------------------------------------------------------------------------------------------
module "all_defaults" {
  source = "../.."

  module_enabled = true
  tags           = local.full_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# Use all params and build an S3 bucket.
# ---------------------------------------------------------------------------------------------------------------------
module "kitchen_sink" {
  source = "../.."

  module_enabled = true

  anyscale_bucket_name = "anyscale-tf-test-bucket-${var.aws_region}"
  force_destroy        = true
  cors_rule = {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST"]
    allowed_origins = ["https://console.anyscale.com"]
    expose_headers  = []
  }

  object_versioning      = true
  server_side_encryption = { sse_algorithm = "AES256" }
  lifecycle_rule = [
    {
      id      = "disabled"
      enabled = false

      filter = {
        tags = {
          some    = "value"
          another = "value2"
        }
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
    },
    {
      id      = "enabled_rule"
      enabled = true

      abort_incomplete_multipart_upload_days = 7

      noncurrent_version_transition = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 60
          storage_class = "ONEZONE_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        },
      ]

      noncurrent_version_expiration = {
        days = 300
      }
    }
  ]

  tags = local.full_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# Do not create any resources
# ---------------------------------------------------------------------------------------------------------------------
module "test_no_resources" {
  source = "../.."

  module_enabled = false
}
