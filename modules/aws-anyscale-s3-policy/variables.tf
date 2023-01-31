# ------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables must be set when using this module.
# ------------------------------------------------------------------------------
variable "anyscale_bucket_name" {
  description = "(Required) The S3 bucket name to apply the policy to."
  type        = string
}

variable "anyscale_iam_access_role_arn" {
  description = "(Required) The Anyscale IAM SteadyState role arn."
  type        = string
}

variable "anyscale_iam_cluster_node_role_arn" {
  description = "(Required) The Anyscale IAM cluster node role arn."
  type        = string
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

variable "module_enabled" {
  description = "(Optional) Whether to create the resources inside this module. Default is `true`."
  type        = bool
  default     = true
}

variable "custom_s3_policy" {
  description = "(Optional) A valid bucket policy in JSON. Default is `null`."
  type        = string
  default     = null
}
