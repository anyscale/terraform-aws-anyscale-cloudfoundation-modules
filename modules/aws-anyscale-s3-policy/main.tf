locals {
  # create_default_policy = var.anyscale_controlplane_role_arn != null && var.anyscale_dataplane_role_arn != null ? true : false

  predefined_policy = templatefile("${path.module}/predefined_s3_policy.tpl", {
    anyscale_bucket_name       = coalesce(var.anyscale_bucket_name, "empty"),
    anyscale_controlplane_role = coalesce(var.anyscale_controlplane_role_arn, "empty"),
    anyscale_dataplane_role    = coalesce(var.anyscale_dataplane_role_arn, "empty")
  })
}

data "aws_iam_policy_document" "anyscale_managed_s3_bucket_policy" {
  source_policy_documents = [local.predefined_policy]

  # Allows using the custom policy if provided.
  override_policy_documents = var.custom_s3_policy != null ? [var.custom_s3_policy] : []
}

resource "aws_s3_bucket_policy" "anyscale_bucket_policy" {
  count = var.module_enabled ? 1 : 0

  bucket = var.anyscale_bucket_name
  policy = data.aws_iam_policy_document.anyscale_managed_s3_bucket_policy.json
}
