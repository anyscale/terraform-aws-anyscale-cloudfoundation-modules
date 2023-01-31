locals {
  create_default_policy = var.custom_s3_policy == null && var.anyscale_iam_access_role_arn != null && var.anyscale_iam_cluster_node_role_arn != null ? true : false
}

data "aws_iam_policy_document" "anyscale_managed_s3_bucket_policy" {
  statement {
    sid     = "AllowSSLRequestsOnly"
    actions = ["s3:*"]
    effect  = "Deny"
    resources = [
      "arn:aws:s3:::${var.anyscale_bucket_name}",
      "arn:aws:s3:::${var.anyscale_bucket_name}/*"
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

  dynamic "statement" {
    for_each = local.create_default_policy ? [1] : [0]
    content {
      sid = "AllowAnyscaleResources"
      actions = [
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:ListBucket"
      ]
      effect = "Allow"
      resources = [
        "arn:aws:s3:::${var.anyscale_bucket_name}",
        "arn:aws:s3:::${var.anyscale_bucket_name}/*"
      ]
      principals {
        type = "AWS"
        identifiers = [
          coalesce(var.anyscale_iam_access_role_arn, "none"),
          coalesce(var.anyscale_iam_cluster_node_role_arn, "none")
        ]
      }
    }
  }
}

resource "aws_s3_bucket_policy" "anyscale_bucket_policy" {
  count = var.module_enabled ? 1 : 0

  bucket = var.anyscale_bucket_name
  policy = coalesce(var.custom_s3_policy, data.aws_iam_policy_document.anyscale_managed_s3_bucket_policy.json)
}
