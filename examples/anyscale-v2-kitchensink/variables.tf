# ---------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# Define these secrets as environment variables
# ---------------------------------------------------------------------------------------------------------------------

# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY

# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# These variables must be set when using this module.
# ---------------------------------------------------------------------------------------------------------------------

variable "aws_region" {
  description = <<-EOF
    (Required) The AWS region in which all resources will be created.

    ex:
    ```
    aws_region = "us-east-2"
    ```
  EOF
  type        = string
}

variable "customer_ingress_cidr_ranges" {
  description = <<-EOT
    The IPv4 CIDR block that is allowed to access the clusters.
    This provides the ability to lock down the v1 stack to just the public IPs of a corporate network.
    This is added to the security group and allows port 443 (https) and 22 (ssh) access.

    While not recommended, you can set this to `0.0.0.0/0` to allow access from anywhere.

    ex:
    ```
    customer_ingress_cidr_ranges = "52.1.1.23/32,10.1.0.0/16"
    ```
  EOT
  type        = string
}

variable "s3_bucket_name" {
  description = <<-EOT
    (Optional) The name of the S3 bucket to use for the kitchen sink.
  EOT
  type        = string
}

variable "anyscale_external_id" {
  description = <<-EOF
    (Required) A string that will be used for the IAM trust policy.
    The trust policy for the control plane IAM role will be locked down to the provided external ID.

    If provided, you must also set `anyscale_org_id` which will be prepended to the external ID.

    ex:
    ```
    anyscale_external_id = "external-id-12345"
    ```
  EOF
  type        = string
}

# ------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These variables have defaults, but may be overridden.
# ------------------------------------------------------------------------------
variable "anyscale_cloud_id" {
  description = <<-EOF
    (Optional) Anyscale Cloud ID.

    This is used to lock down the cross account access role by Cloud ID. Because the Cloud ID is unique to each
    customer, this ensures that only the customer can access their own resources. The Cloud ID is not known until the
    Cloud is created, so this is an optional variable.

    ex:
    ```
    anyscale_cloud_id = "cld_abcdefghijklmnop1234567890"
    ```
  EOF
  type        = string
  default     = null
  validation {
    condition = (
      var.anyscale_cloud_id == null ? true : (
        length(var.anyscale_cloud_id) > 4 &&
        substr(var.anyscale_cloud_id, 0, 4) == "cld_"
      )
    )
    error_message = "The anyscale_cloud_id value must start with \"cld_\"."
  }
}

variable "anyscale_org_id" {
  description = <<-EOT
    (Optional) Anyscale Organization ID.

    This is used to lock down the cross account access role by Organization ID. Because the Organization ID is unique to each
    customer, this ensures that only the customer can access their own resources.

    ex:
    ```
    anyscale_org_id = "org_abcdefghijklmn1234567890"
    ```
  EOT
  type        = string
  default     = null
  validation {
    condition = (
      var.anyscale_org_id == null ? true : (
        length(var.anyscale_org_id) > 4 &&
        substr(var.anyscale_org_id, 0, 4) == "org_"
      )
    )
    error_message = "The anyscale_org_id value must start with \"org_\"."
  }
}

variable "tags" {
  description = <<-EOF
    (Optional) A map of tags.
    These tags will be added to all cloud resources that accept tags.
    ex:
    ```
    tags = {
      "environment" = "test",
      "team" = "anyscale"
    }
    ```
  EOF
  type        = map(string)
  default = {
    "test" : true,
    "environment" : "test"
  }
}

# Vars for IAM Secrets access
variable "anyscale_cluster_node_byod_secret_arns" {
  description = <<-EOT
    (Optional) A list of Secrets Manager ARNs.
    The Secrets Manager secret ARNs that the cluster node role needs access to for BYOD clusters.

    ex:
    ```
    anyscale_cluster_node_secret_arns = [
      "arn:aws:secretsmanager:us-east-1:123456789012:secret:my-secret-1",
      "arn:aws:secretsmanager:us-east-1:123456789012:secret:my-secret-2",
    ]
    ```
  EOT
  type        = list(string)
  default     = []
}

variable "anyscale_cluster_node_byod_secret_kms_arn" {
  description = <<-EOT
    (Optional) The KMS key ARN that the Secrets Manager secrets are encrypted with.
    This is only used if `anyscale_cluster_node_byod_secret_arns` is also provided.

    ex:
    ```
    anyscale_cluster_node_secret_arns = [
      "arn:aws:secretsmanager:us-east-1:123456789012:secret:my-secret-1",
      "arn:aws:secretsmanager:us-east-1:123456789012:secret:my-secret-2",
    ]
    anyscale_cluster_node_secret_kms_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
    # checkov:skip=CKV_SECRET_6
    ```
  EOT
  type        = string
  default     = null
}

variable "security_group_enable_ssh_access" {
  description = <<-EOT
    (Optional) Determines if SSH access (port 22) should be enabled in the security group.

    When set to true, SSH access will be allowed from the CIDR ranges specified in
    `customer_ingress_cidr_ranges`. When false, only HTTPS access (port 443) will be allowed.

    ex:
    ```
    security_group_enable_ssh_access = false
    ```
  EOT
  type        = bool
  default     = true
}

variable "anyscale_s3_force_destroy" {
  description = "This is used to set the S3 force destroy value for testing purposes"
  type        = bool
  default     = false
}
