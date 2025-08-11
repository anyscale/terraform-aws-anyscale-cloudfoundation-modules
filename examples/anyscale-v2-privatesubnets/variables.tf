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

variable "anyscale_org_id" {
  description = <<-EOF
    (Required) Anyscale Organization ID.
    This is used for tagging resources.
    If the variable `anyscale_external_id` is provided, this is also
    prepended to the external ID for the control plane IAM role trust policy.

    ex:
    ```
    anyscale_org_id = "org_1234567890"
    ```
  EOF
  type        = string
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

variable "s3_tag_value" {
  description = "This is used to set the S3 tag value for testing purposes"
  type        = string
  default     = "testing"
}

variable "anyscale_s3_force_destroy" {
  description = "This is used to set the S3 force destroy value for testing purposes"
  type        = bool
  default     = false
}
