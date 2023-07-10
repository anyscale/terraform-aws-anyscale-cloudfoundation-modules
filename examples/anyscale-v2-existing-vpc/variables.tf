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

variable "existing_vpc_id" {
  description = <<-EOT
    (Required) Existing VPC ID.
    The ID of an existing VPC to use. This should not be the entire ARN of the VPC, just the ID.
    ex:
    ```
    existing_vpc_id = "vpc-1234567890"
    ```
    ```
  EOT
  type        = string
  validation {
    condition = (
      length(var.existing_vpc_id) > 4 &&
      substr(var.existing_vpc_id, 0, 4) == "vpc-"
    )
    error_message = "The existing_vpc_id must be set and shoudl start with \"vpc-\"."
  }
}

variable "existing_subnet_ids" {
  description = <<-EOT
    (Required) Existing Subnet IDs.
    The IDs of existing subnets to use. This should not be the entire ARN of the subnet, just the ID.
    These subnets should be in the `existing_vpc_id`.
    ex:
    ```
    existing_subnet_ids = ["subnet-1234567890", "subnet-0987654321"]
    ```
  EOT
  type        = list(string)
  validation {
    condition = (
      length(var.existing_subnet_ids) > 0
    )
    error_message = "The existing_subnet_ids must be set and should be a list of subnet IDs."
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

variable "anyscale_deploy_env" {
  description = "(Optional) Anyscale deploy environment. Used in resource names and tags."
  type        = string
  validation {
    condition = (
      var.anyscale_deploy_env == "production" || var.anyscale_deploy_env == "development" || var.anyscale_deploy_env == "test"
    )
    error_message = "The anyscale_deploy_env only allows `production`, `test`, or `development`"
  }
  default = "production"
}

variable "tags" {
  description = "(Optional) A map of tags to all resources that accept tags."
  type        = map(string)
  default = {
    "test" : true,
    "environment" : "test"
  }
}

variable "customer_ingress_cidr_ranges" {
  description = <<-EOT
    The IPv4 CIDR block that is allowed to access the clusters.
    This provides the ability to lock down the v1 stack to just the public IPs of a corporate network.
    This is added to the security group and allows port 443 (https) and 22 (ssh) access.
    ex: `52.1.1.23/32,10.1.0.0/16'
  EOT
  type        = string
}

variable "s3_tag_value" {
  description = "This is used to set the S3 tag value for testing purposes"
  type        = string
}
