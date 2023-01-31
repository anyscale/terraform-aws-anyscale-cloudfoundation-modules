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

variable "anyscale_efs_name" {
  description = "(Optional) Elastic file system name. Will default to `efs_anyscale` if this var `null` and anyscale_cloud_id is also `null`. Default is `null`."
  type        = string
  default     = null
}

variable "tags" {
  description = "(Optional) A map of tags to add to all resources. Default is none."
  type        = map(string)
  default     = {}
}

# ------------
# File System
# ------------
variable "availability_zone_name" {
  description = "(Optional) The AWS Availability Zone in which to create the file system. Used to create a file system that uses One Zone storage classes. Default is `null`."
  type        = string
  default     = null
}

variable "efs_creation_token" {
  description = "(Optional) A unique token used as reference when creating the Elastic File System to ensure idempotent file system creation. Default is `null` which forces Terraform to generate it."
  type        = string
  default     = null
}

variable "efs_performance_mode" {
  description = "(Optional) The file system performance mode. Can be either `generalPurpose` or `maxIO`. Default is `generalPurpose`"
  type        = string
  default     = "generalPurpose"
  validation {
    condition     = contains(["generalPurpose", "maxIO"], var.efs_performance_mode)
    error_message = "The efs_performance_mode value must either be `generalPurpose` or `maxIO`."
  }
}

variable "efs_encrypted" {
  description = "(Optional) Deterimnes if the elastic file system disk will be encrypted. Default is `true`."
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "(Optional) The ARN for the KMS encryption key. When specifying `kms_key_arn`, efs_encrypted needs to be set to `true`. Default is `null`."
  type        = string
  default     = null
}

variable "efs_throughput_mode" {
  description = "(Optional) Throughput mode for the file system. Defaults to `bursting`. Valid values: `bursting`, `provisioned`. When using `provisioned`, also set `provisioned_throughput_in_mibps`. Default is `bursting`."
  type        = string
  default     = "bursting"
  validation {
    condition     = contains(["bursting", "provisioned"], var.efs_throughput_mode)
    error_message = "The efs_throughput_mode value must either be `bursting` or `provisioned`."
  }
}
variable "provisioned_throughput_in_mibps" {
  description = "(Optional) The throughput, measured in MiB/s, that you want to provision for the file system. Only applicable with `throughput_mode` set to `provisioned`"
  type        = number
  default     = null
}

variable "lifecycle_policy_transition_to_ia" {
  description = "(Optional) Indicates how long it takes to transition files to Infrequent Access storage class. No value, or an empty list, means never. Default is to transition to IA after 60 days."
  type        = list(string)
  default     = ["AFTER_60_DAYS"]
  validation {
    condition = (
      length(var.lifecycle_policy_transition_to_ia) == 1 ? contains(["AFTER_7_DAYS", "AFTER_14_DAYS", "AFTER_30_DAYS", "AFTER_60_DAYS", "AFTER_90_DAYS"], var.lifecycle_policy_transition_to_ia[0]) : length(var.lifecycle_policy_transition_to_ia) == 0
    )
    error_message = "`lifecycle_policy_transition_to_ia` must either be empty list or one of \"AFTER_7_DAYS\", \"AFTER_14_DAYS\", \"AFTER_30_DAYS\", \"AFTER_60_DAYS\", \"AFTER_90_DAYS\"."
  }
}

variable "lifecycle_policy_transition_to_primary_storage_class" {
  type        = list(string)
  description = "(Optional) Indicates the policy used to transition a file from Infrequent Access (IA) storage to primary storage. Default is `AFTER_1_ACCESS`."
  default     = ["AFTER_1_ACCESS"]
  validation {
    condition = (
      length(var.lifecycle_policy_transition_to_primary_storage_class) == 1 ? contains(["AFTER_1_ACCESS"], var.lifecycle_policy_transition_to_primary_storage_class[0]) : length(var.lifecycle_policy_transition_to_primary_storage_class) == 0
    )
    error_message = "Var `lifecycle_policy_transition_to_primary_storage_class` must either be empty list or \"AFTER_1_ACCESS\"."
  }
}

# -------------------
# File System Policy
# -------------------
variable "attach_policy" {
  description = "(Optional) Determines whether a policy is attached to the file system. Default is `true`."
  type        = bool
  default     = true
}

variable "bypass_policy_lockout_safety_check" {
  description = "(Optional) A flag to indicate whether to bypass the `aws_efs_file_system_policy` lockout safety check. Default is `false`"
  type        = bool
  default     = false
}

variable "source_policy_documents" {
  description = "(Optional) List of IAM policy documents that are merged together into the exported document. Statements must have unique `sid`s. Default is an empty list."
  type        = list(string)
  default     = []
}

variable "override_policy_documents" {
  description = "(Optional) List of IAM policy documents that are merged together into the exported document. In merging, statements with non-blank `sid`s will override statements with the same `sid`. Default is an empty list."
  type        = list(string)
  default     = []
}

variable "policy_statements" {
  description = "(Optional) A list of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom permission usage. Default is an empty list."
  type        = any
  default     = []
}

# ----------------
# Mount Target(s)
# ----------------
# ex:
# mount_targets = {
#   subnet1 = {
#     subnet_id = "subnet-01234567890abcdef"
#   }
# }
# ex:
# mount_targets = {
#   1 = {
#     ip_address = "172.16.0.0",
#     subnet_id = "subnet-01234567890abcdef",
#     security_groups = "sg-12999ac9dff"
#   },
#   2 = {
#     ip_address = "172.17.0.0",
#     subnet_id = "subnet-123457890abcdefg",
#     security_groups = "sg-12999ac9dff"
#   }
# }
# variable "mount_targets" {
#   description = "(Optional) A map of subnets IDs. Default is an empty map."
#   type = map(object({
#     security_group_ids = list(string)
#     subnet_ids         = list(string)
#   }))
#   default = {}
# }

variable "mount_targets_subnets" {
  description = "(Optional) List of mount target subnets. Default is an empty list."
  type        = list(string)
  default     = []
}

variable "mount_targets_subnet_count" {
  description = "(Optional) The mount targets subnet count. This is included as the number of subnets is not always known at the creation time. Default is `0`."
  type        = number
  default     = 0
}
variable "mount_target_ips" {
  description = "(Optional) List of Target IPs. These should map to the list of mount target subnets. Default is an empty list."
  type        = list(string)
  default     = []
}

# ---------------
# Security Group
# ---------------
variable "associated_security_group_ids" {
  description = "(Optional) A list of security group IDs to add to the mount targets. Default is an empty list."
  type        = list(string)
  default     = []
}

# ----------------
# Access Point(s)
# ----------------
# ex:
# access_points = {
#   posix_example = {
#     name = "posix-example"
#     posix_user = {
#       gid            = 1001
#       uid            = 1001
#       secondary_gids = [1002]
#      }
#   }
#   root_example = {
#     root_directory = {
#       path = "/example"
#       creation_info = {
#         owner_gid   = 1001
#         owner_uid   = 1001
#         permissions = "755"
#       }
#     }
#   }
# }
variable "access_points" {
  description = "(Optional) A map of access point definitions to create. Default is none."
  type        = any
  default     = {}
}

# --------------
# Backup Policy
# --------------
variable "create_backup_policy" {
  description = "(Optional) Determines whether a backup policy is created. Default is `true`."
  type        = bool
  default     = true
}

variable "enable_backup_policy" {
  description = "(Optional) Determines whether a backup policy is `ENABLED` or `DISABLED`. Default is `true`."
  type        = bool
  default     = true
}

# --------------------------
# Replication Configuration
# --------------------------
variable "create_replication_configuration" {
  description = "(Optional) Determines whether a replication configuration is created. Default is `false`."
  type        = bool
  default     = false
}

# ex:
# replication_configuration_destination = {
#   availability_zone_name = "us-west-2b"
#   kms_key_id = "1234abcd-12ab-34cd-56ef-1234567890ab""
# }
# ex:
# replication_configuration_destination = {
#   region = "us-east-2"
# }
variable "replication_configuration_destination" {
  description = "(Optional) A destination configuration block. Default is none."
  type        = any
  default     = {}
}
