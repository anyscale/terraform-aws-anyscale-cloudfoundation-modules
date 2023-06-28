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
  description = "The AWS region in which all resources will be created."
  type        = string
}

variable "anyscale_deploy_env" {
  description = "(Required) Anyscale deploy environment. Used in resource names and tags."
  type        = string
  validation {
    condition = (
      var.anyscale_deploy_env == "production" || var.anyscale_deploy_env == "development" || var.anyscale_deploy_env == "test"
    )
    error_message = "The anyscale_deploy_env only allows `production`, `test`, or `development`"
  }
}

# ------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These variables have defaults, but may be overridden.
# ------------------------------------------------------------------------------
variable "anyscale_cloud_id" {
  description = "(Optional) Anyscale Cloud ID. Default is `null`."
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
  description = "(Optional) A map of tags to all resources that accept tags."
  type        = map(string)
  default = {
    "test" : true,
    "environment" : "test"
  }
}

variable "common_prefix" {
  description = <<-EOT
    (Optional)
    Default for this EXAMPLE is `anyscale-pfx-test-`
  EOT
  type        = string
  default     = "anyscale-pfx-test-"
  validation {
    condition     = var.common_prefix == null || try(length(var.common_prefix) <= 30, false)
    error_message = "common_prefix must either be `null` or less than 30 characters."
  }
}

variable "s3_tag_value" {
  description = "This is used to set the S3 tag value for testing purposes"
  type        = string
}

variable "anyscale_access_role_trusted_role_arns" {
  description = <<-EOT
    (Optional)
    A list of ARNs of IAM roles that are allowed to assume the Anyscale IAM access role.
    Default is an empty list and the default in the `aws-anyscale-iam` sub-module is used.
  EOT
  type        = list(string)
  default     = []
}
