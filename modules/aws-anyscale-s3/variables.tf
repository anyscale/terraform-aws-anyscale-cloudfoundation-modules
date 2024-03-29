# ------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables must be set when using this module.
# ------------------------------------------------------------------------------

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

variable "anyscale_bucket_name" {
  description = "(Optional - forces new resource) The name of the bucket. Conflicts with anyscale_bucket_prefix. Default is `null`."
  type        = string
  default     = null
}

variable "anyscale_bucket_prefix" {
  description = "(Optional - forces new resource) Creates a unique bucket name beginning with the specified prefix. Conflicts with anyscale_bucket_name. Default is `anyscale-`."
  type        = string
  default     = "anyscale-"
}

variable "force_destroy" {
  description = <<-EOT
    (Optional) Set to true to delete all objects from the bucket so that the bucket can be destroyed without error.
    These objects are not recoverable.
    Default is `false`. With this default, you need to empty the bucket if there are objects before `terraform destroy` can be completed.
  EOT
  type        = bool
  default     = false
}

# Example:
#
# cors_rule = {
#   allowed_headers = ["*"]
#   allowed_methods = ["PUT", "POST"]
#   allowed_origins = ["https://s3-website-test.example.com"]
#   expose_headers  = ["ETag"]
#   max_age_seconds = 3000
# }
variable "cors_rule" {
  description = <<-EOT
    (Optional)
    Object containing a rule of Cross-Origin Resource Sharing.
    The default allows GET, POST, PUT, HEAD, and DELETE
    access for the purpose of viewing logs and other functionality
    from within the Anyscale Web UI (*.anyscale.com).

    ex:
    ```
    cors_rule = {
      allowed_headers = ["*"]
      allowed_methods = [GET", "POST", "PUT", "HEAD", "DELETE"]
      allowed_origins = ["https://*.anyscale.com"]
    }
    ```
  EOT
  type        = any
  default = {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST", "PUT", "HEAD", "DELETE"]
    allowed_origins = ["https://*.anyscale.com"]
    expose_headers  = []
  }
}

variable "object_versioning" {
  description = "(Optional) Boolean specifying object versioning configuration. Default is `false`."
  type        = bool
  default     = false
}

# Example:
#
# logging = {
#   target_bucket = "example-bucket"
#   target_prefix = "log/"
# }
variable "logging" {
  description = "(Optional) Map containing access bucket logging configuration. Default is an empty map."
  type        = map(string)
  default     = {}
}

# Example:
#
# server_side_encryption = {
#   kms_master_key_id = "key_id"
#   sse_algorithm     = "aws:kms"
# }
variable "server_side_encryption" {
  description = <<-EOT
    (Optional)
    Map containing server-side encryption configuration.

    ex using KMS:
    ```
    server_side_encryption = {
      kms_master_key_id = "key_id"
      sse_algorithm     = "aws:kms"
    }
    ```

    ex using AES256 (default):
    ```
    server_side_encryption = {
      sse_algorithm = "AES256"
    }
    ```
  EOT
  type        = map(string)
  default = {
    sse_algorithm = "AES256"
  }
}

# Example:
#
# lifecycle_rule = [
#   {
#     id      = "log"
#     enabled = true

#     filter = {
#       tags = {
#         some    = "value"
#         another = "value2"
#       }
#     }

#     transition = [
#       {
#         days          = 30
#         storage_class = "ONEZONE_IA"
#         }, {
#         days          = 60
#         storage_class = "GLACIER"
#       }
#     ]
#   },
#   {
#     id                                     = "log1"
#     enabled                                = true
#     abort_incomplete_multipart_upload_days = 7

#     noncurrent_version_transition = [
#       {
#         days          = 30
#         storage_class = "STANDARD_IA"
#       },
#       {
#         days          = 60
#         storage_class = "ONEZONE_IA"
#       },
#       {
#         days          = 90
#         storage_class = "GLACIER"
#       },
#     ]

#     noncurrent_version_expiration = {
#       days = 300
#     }
#   },
#   {
#     id      = "log2"
#     enabled = true

#     filter = {
#       prefix                   = "log1/"
#       object_size_greater_than = 200000
#       object_size_less_than    = 500000
#       tags = {
#         some    = "value"
#         another = "value2"
#       }
#     }

#     noncurrent_version_transition = [
#       {
#         days          = 30
#         storage_class = "STANDARD_IA"
#       },
#     ]

#     noncurrent_version_expiration = {
#       days = 300
#     }
#   },
# ]
variable "lifecycle_rule" {
  description = "(Optional) List of maps containing configuration of object lifecycle management. Default is an empty list."
  type        = any
  default     = []
}

variable "tags" {
  description = "(Optional) A map of tags to all resources that accept tags."
  type        = map(string)
  default     = {}
}
