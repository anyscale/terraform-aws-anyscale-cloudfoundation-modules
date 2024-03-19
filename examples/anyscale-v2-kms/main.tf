# ---------------------------------------------------------------------------------------------------------------------
# Create core Anyscale v2 Stack resources with minimal parameters but a common name
#   Should be executed in us-east-2
#   Creates a v2 stack including
#     - IAM Roles
#     - S3 Bucket
#     - VPC with publicly routed subnets (no private subnets)
#     - VPC Security Groups
#     - EFS
# ---------------------------------------------------------------------------------------------------------------------
locals {
  full_tags = merge(tomap({
    anyscale-cloud-id           = var.anyscale_cloud_id,
    anyscale-deploy-environment = var.anyscale_deploy_env
    }),
    var.tags
  )
}

# Create a KMS Key that will be used to encrypt EFS and the S3 bucket
#tfsec:ignore:aws-kms-auto-rotate-keys
resource "aws_kms_key" "anyscale_v2_kms" {
  #checkov:skip=CKV_AWS_7:Rotation not required for this example
  description             = "Anyscale Terraform Example v2 KMS Key"
  deletion_window_in_days = 7
  policy                  = data.aws_iam_policy_document.anyscale_v2_kms_policy.json
}

# Create a policy that will be attached to the KMS Key that allows the Anyscale IAM Roles to use the KMS Key
#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "anyscale_v2_kms_policy" {
  #checkov:skip=CKV_AWS_111:Constraints are handled outside of this example policy
  #checkov:skip=CKV_AWS_356:Allowed wildcards
  #checkov:skip=CKV_AWS_109:Constraints are handled outside of this example policy
  # Default policy - account wide access to all key operations
  statement {
    sid       = "Default"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  # Allow the Key Administrators to manage the KMS Key
  statement {
    sid = "AllowKeyAdministrators"
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion"
    ]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.key_admin_role_name}"]
    }
  }

  # Allow the Anyscale IAM Roles to use the KMS Key
  statement {
    sid       = "AllowAnyscaleRoles"
    actions   = ["kms:Decrypt", "kms:Encrypt", "kms:ReEncrypt*", "kms:GenerateDataKey*", "kms:DescribeKey"]
    resources = ["*"]
    principals {
      type = "AWS"
      identifiers = [
        module.aws_anyscale_v2_kms.anyscale_iam_role_arn,
        module.aws_anyscale_v2_kms.anyscale_iam_role_cluster_node_arn
      ]
    }
  }
}


module "aws_anyscale_v2_kms" {
  source = "../.." #this should be changed if executing this example outside of this repository
  tags   = local.full_tags

  anyscale_deploy_env = var.anyscale_deploy_env
  anyscale_cloud_id   = var.anyscale_cloud_id
  anyscale_org_id     = var.anyscale_org_id

  create_cluster_node_cloudwatch_policy = true

  # VPC Related
  anyscale_vpc_cidr_block     = "172.24.0.0/16"
  anyscale_vpc_public_subnets = ["172.24.21.0/24", "172.24.22.0/24", "172.24.23.0/24"]

  common_prefix   = var.common_prefix
  use_common_name = true

  # Security Group Related
  security_group_ingress_allow_access_from_cidr_range = var.customer_ingress_cidr_ranges

  # S3 Bucket Related
  anyscale_s3_server_side_encryption = {
    kms_master_key_id = aws_kms_key.anyscale_v2_kms.key_id
    sse_algorithm     = "aws:kms"
  }

  # EFS Related
  efs_kms_key_id = aws_kms_key.anyscale_v2_kms.arn
}
