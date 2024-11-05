locals {
  cors_enabled    = length(keys(var.cors_rule)) > 0
  logging_enabled = length(keys(var.logging)) > 0
  sse_enabled     = length(keys(var.server_side_encryption)) > 0

  cors = local.cors_enabled ? [var.cors_rule] : []
  # logging    = local.logging_enabled ? [var.logging] : []
  # encryption = local.sse_enabled ? [var.apply_server_side_encryption_by_default] : []
  lifecycle_rules = try(jsondecode(var.lifecycle_rule), var.lifecycle_rule)

  anyscale_bucketname    = try(var.anyscale_bucket_name, null)
  anyscale_bucket_prefix = local.anyscale_bucketname != null ? null : var.anyscale_bucket_prefix

  module_tags = tomap({
    tf_sub_module     = "aws-anyscale-s3",
    anyscale_cloud_id = try(var.anyscale_cloud_id, "")
  })
}

#trivy:ignore:avd-aws-0089 #trivy:ignore:avd-aws-0090 #trivy:ignore:avd-aws-0132
resource "aws_s3_bucket" "anyscale_managed_s3_bucket" {
  #checkov:skip=CKV_AWS_145:Encryption is managed below as a customer choice
  #checkov:skip=CKV_AWS_144:Replication is managed as a choice
  #checkov:skip=CKV_AWS_18:Encryption is managed below as a customer choice
  #checkov:skip=CKV_AWS_19:Encryption is managed below as a customer choice
  #checkov:skip=CKV2_AWS_62:Event notification is not required for this bucket.
  #checkov:skip=CKV2_AWS_6:Bucket policy is managed below as a customer choice
  #checkov:skip=CKV_AWS_21:Bucket versioning is managed below as a customer choice
  #checkov:skip=CKV2_AWS_61:Bucket policy is managed below as a customer choice
  count = var.module_enabled ? 1 : 0

  bucket        = local.anyscale_bucketname
  bucket_prefix = local.anyscale_bucket_prefix
  force_destroy = var.force_destroy
  tags = merge(
    var.tags,
    local.module_tags
  )
}

#trivy:ignore:avd-aws-0132
resource "aws_s3_bucket_server_side_encryption_configuration" "anyscale_managed_s3_bucket" {
  count  = var.module_enabled && local.sse_enabled ? 1 : 0
  bucket = aws_s3_bucket.anyscale_managed_s3_bucket[0].id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = lookup(var.server_side_encryption, "kms_master_key_id", null)
      sse_algorithm     = lookup(var.server_side_encryption, "sse_algorithm", lookup(var.server_side_encryption, "kms_master_key_id", null) == null ? "AES256" : "aws:kms")
    }
    bucket_key_enabled = lookup(var.server_side_encryption, "kms_master_key_id", null) == null ? false : true
  }
}

resource "aws_s3_bucket_cors_configuration" "anyscale_managed_s3_bucket" {
  count  = var.module_enabled && local.cors_enabled ? 1 : 0
  bucket = aws_s3_bucket.anyscale_managed_s3_bucket[0].id

  dynamic "cors_rule" {
    for_each = local.cors

    content {
      allowed_headers = try(cors_rule.value.allowed_headers, null)
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = try(cors_rule.value.expose_headers, null)
      max_age_seconds = try(cors_rule.value.max_age_seconds, null)
    }
  }
}

resource "aws_s3_bucket_versioning" "anyscale_managed_s3_bucket" {
  count  = var.module_enabled && var.object_versioning ? 1 : 0
  bucket = aws_s3_bucket.anyscale_managed_s3_bucket[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "anyscale_managed_s3_bucket" {
  count  = var.module_enabled && local.logging_enabled ? 1 : 0
  bucket = aws_s3_bucket.anyscale_managed_s3_bucket[0].id

  target_bucket = var.logging["target_bucket"]
  target_prefix = try(var.logging["target_prefix"], null)
}

resource "aws_s3_bucket_public_access_block" "anyscale_managed_s3_bucket" {
  count  = var.module_enabled ? 1 : 0
  bucket = aws_s3_bucket.anyscale_managed_s3_bucket[0].id
  # depends_on = [aws_s3_bucket_policy.anyscale_managed_s3_bucket_policy]

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}



resource "aws_s3_bucket_lifecycle_configuration" "anyscale_managed_s3_bucket" {
  #checkov:skip=CKV_AWS_300:Lifecycle rules are managed below as a customer choice
  count = var.module_enabled && length(local.lifecycle_rules) > 0 ? 1 : 0

  bucket = aws_s3_bucket.anyscale_managed_s3_bucket[0].id

  dynamic "rule" {
    for_each = local.lifecycle_rules

    content {
      id     = try(rule.value.id, null)
      status = try(rule.value.enabled ? "Enabled" : "Disabled", tobool(rule.value.status) ? "Enabled" : "Disabled", title(lower(rule.value.status)))

      # Max 1 block - abort_incomplete_multipart_upload
      dynamic "abort_incomplete_multipart_upload" {
        for_each = try([rule.value.abort_incomplete_multipart_upload_days], [])

        content {
          days_after_initiation = try(rule.value.abort_incomplete_multipart_upload_days, null)
        }
      }


      # Max 1 block - expiration
      dynamic "expiration" {
        for_each = try(flatten([rule.value.expiration]), [])

        content {
          date                         = try(expiration.value.date, null)
          days                         = try(expiration.value.days, null)
          expired_object_delete_marker = try(expiration.value.expired_object_delete_marker, null)
        }
      }

      # Several blocks - transition
      dynamic "transition" {
        for_each = try(flatten([rule.value.transition]), [])

        content {
          date          = try(transition.value.date, null)
          days          = try(transition.value.days, null)
          storage_class = transition.value.storage_class
        }
      }

      # Max 1 block - noncurrent_version_expiration
      dynamic "noncurrent_version_expiration" {
        for_each = try(flatten([rule.value.noncurrent_version_expiration]), [])

        content {
          newer_noncurrent_versions = try(noncurrent_version_expiration.value.newer_noncurrent_versions, null)
          noncurrent_days           = try(noncurrent_version_expiration.value.days, noncurrent_version_expiration.value.noncurrent_days, null)
        }
      }

      # Several blocks - noncurrent_version_transition
      dynamic "noncurrent_version_transition" {
        for_each = try(flatten([rule.value.noncurrent_version_transition]), [])

        content {
          newer_noncurrent_versions = try(noncurrent_version_transition.value.newer_noncurrent_versions, null)
          noncurrent_days           = try(noncurrent_version_transition.value.days, noncurrent_version_transition.value.noncurrent_days, null)
          storage_class             = noncurrent_version_transition.value.storage_class
        }
      }

      # Max 1 block - filter - without any key arguments or tags
      dynamic "filter" {
        for_each = length(try(flatten([rule.value.filter]), [])) == 0 ? [true] : []

        content {
          #          prefix = ""
        }
      }

      # Max 1 block - filter - with one key argument or a single tag
      dynamic "filter" {
        for_each = [for v in try(flatten([rule.value.filter]), []) : v if max(length(keys(v)), length(try(rule.value.filter.tags, rule.value.filter.tag, []))) == 1]

        content {
          object_size_greater_than = try(filter.value.object_size_greater_than, null)
          object_size_less_than    = try(filter.value.object_size_less_than, null)
          prefix                   = try(filter.value.prefix, null)

          dynamic "tag" {
            for_each = try(filter.value.tags, filter.value.tag, [])

            content {
              key   = tag.key
              value = tag.value
            }
          }
        }
      }

      # Max 1 block - filter - with more than one key arguments or multiple tags
      dynamic "filter" {
        for_each = [for v in try(flatten([rule.value.filter]), []) : v if max(length(keys(v)), length(try(rule.value.filter.tags, rule.value.filter.tag, []))) > 1]

        content {
          and {
            object_size_greater_than = try(filter.value.object_size_greater_than, null)
            object_size_less_than    = try(filter.value.object_size_less_than, null)
            prefix                   = try(filter.value.prefix, null)
            tags                     = try(filter.value.tags, filter.value.tag, null)
          }
        }
      }
    }
  }

  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.anyscale_managed_s3_bucket]
}
