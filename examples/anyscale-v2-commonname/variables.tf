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
    The AWS region in which all resources will be created.
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

# ------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These variables have defaults, but may be overridden.
# ------------------------------------------------------------------------------
variable "anyscale_deploy_env" {
  description = <<-EOF
    (Optional) Anyscale deployment environment. Used in resource names and tags.
    ex:
    ```
    anyscale_deploy_env = "production"
    ```
  EOF
  type        = string
  validation {
    condition = (
      var.anyscale_deploy_env == "production" || var.anyscale_deploy_env == "development" || var.anyscale_deploy_env == "test"
    )
    error_message = "The anyscale_deploy_env only allows `production`, `test`, or `development`"
  }
  default = "production"
}

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
