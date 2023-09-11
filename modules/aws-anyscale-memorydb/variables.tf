# ------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables must be set when using this module.
# ------------------------------------------------------------------------------
variable "memorydb_subnet_ids" {
  description = <<-EOT
    (Required) A list of subnet IDs

    This should be existing Subnet IDs or from the `aws-anyscale-vpc` sub module. These subnets will be associated with the MemoryDB subnet group.

    ex:
    ```
    memorydb_subnet_ids = [
      "subnet-1234567890",
      "subnet-0987654321"
    ]
    ```
  EOT
  type        = list(string)
}

variable "memorydb_security_group_ids" {
  description = <<-EOT
    (Required) A list of security group IDs

    This should be existing Security Group IDs or from the `aws-anyscale-securitygroups` sub module. These security groups will be associated with the MemoryDB cluster.

    ex:
    ```
    memorydb_security_group_ids = [
      "sg-1234567890",
      "sg-0987654321"
    ]
    ```
  EOT
  type        = list(string)
}

# ------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These variables have defaults, but may be overridden.
# ------------------------------------------------------------------------------
variable "anyscale_cloud_id" {
  description = <<-EOT
    (Optional) Anyscale Cloud ID.

    Used in Tags and Permissions.

    ex:
    ```
    anyscale_cloud_id = "cld_1234567890"
    ```
  EOT
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
  description = <<-EOT
    (Optional) Determines if this module is enabled and resources are created.

    ex:
    ```
    module_enabled = false
    ```
  EOT
  type        = bool
  default     = false
}

variable "tags" {
  description = <<-EOT
    (Optional) A map of tags to be added.

    ex:
    ```
    tags = {
      application = "Anyscale",
      environment = "prod"
    }
    ```
  EOT
  type        = map(string)
  default     = {}
}

#-------------------------
# MemoryDB Related
#-------------------------
variable "anyscale_memorydb_name" {
  description = <<-EOT
    (Optional) Name for the Anyscale Memory DB.

    If left `null`, will default to `anyscale_memorydb_name_prefix`.
    If provided, overrides the `anyscale_memorydb_name_prefix` variable.

    ex:
    ```
    anyscale_memorydb_name = "anyscale-memorydb"
    ```
  EOT
  type        = string
  default     = null
  validation {
    condition     = var.anyscale_memorydb_name == null ? true : (can(regex("^[a-z0-9-]*$", var.anyscale_memorydb_name)))
    error_message = "The `anyscale_memorydb_name` variable must `null` or contain only lowercase alphanumeric characters and hyphens."
  }
}
variable "anyscale_memorydb_name_prefix" {
  description = <<-EOT
    (Optional) Name prefix for the Anyscale Memory DB.

    If `anyscale_memorydb_name` is provided, it will override this variable.
    Default is `null` but is set to `anyscale-mdb-` in a local variable.

    ex:
    ```
    anyscale_memorydb_name_prefix = "anyscale-mdb-"
    ```
  EOT
  type        = string
  default     = null
  validation {
    condition     = var.anyscale_memorydb_name_prefix == null ? true : (can(regex("^[a-z0-9-]*$", var.anyscale_memorydb_name_prefix)) && length(var.anyscale_memorydb_name_prefix) <= 14)
    error_message = "The `anyscale_memorydb_name_prefix` variable must be `null` or contain only lowercase alphanumeric characters and hyphens and less then 14 characters."
  }
}

variable "anyscale_memorydb_description" {
  description = <<-EOT
    (Optional) A description of the secret

    This should be a meaningful description of the Memory DB.

    ex:
    ```
    anyscale_memorydb_description = "Anyscale MemoryDB for Anyscale Services"
    ```
  EOT
  type        = string
  default     = "Anyscale managed MemoryDB for Anyscale Services"
}

variable "memorydb_kms_key_arn" {
  description = <<-EOT
    (Optional) KMS Key ARN or Id

    AWS KMS key to be used to encrypt the MemoryDB.
    If you don't specify this value, then MemoryDB defaults to using the AWS account's default KMS key.

    ex:
    ```
    kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
    ```
  EOT
  type        = string
  default     = null
}

variable "memorydb_engine_version" {
  description = <<-EOT
    (Optional) The version number of the Redis engine to be used.

    The following are the supported versions:

    * `7.0`
    * `6.2`

    ex:
    ```
    memorydb_engine_version = "7.0"
    ```
  EOT
  type        = string
  default     = "7.0"
  validation {
    condition = (
      var.memorydb_engine_version == "7.0" ||
      var.memorydb_engine_version == "6.2"
    )
    error_message = "The memorydb_engine_version value must be either \"7.0\", \"6.2\"."
  }
}

variable "enable_auto_minor_version_upgrade" {
  description = <<-EOT
    (Optional) Determines if minor engine upgrades will be applied automatically

    This only applies to the underlying MemoryDB cluster during the maintenance window.

    ex:
    ```
    enable_auto_minor_version_upgrade = true
    ```
  EOT
  type        = bool
  default     = true
}

variable "memorydb_maintenance_window" {
  description = <<-EOT
    (Optional) The weekly time range (in UTC) during which system maintenance can occur.

    Please remember that the maintenance window and the snapshot window cannot overlap.

    ex:
    ```
    memorydb_maintenance_window = "sun:05:00-sun:09:00"
    ```
  EOT
  type        = string
  default     = null
}

variable "memorydb_port" {
  description = <<-EOT
    (Optional) The port number on which each of the nodes accepts connections.

    The default is `6379`.

    ex:
    ```
    memorydb_port = 6379
    ```
  EOT
  type        = number
  default     = 6379
}

variable "memorydb_node_type" {
  description = <<-EOT
    (Optional) The node types to use in the MemoryDB.

    The node type helps define the compute and memory capacity of the nodes in the node group.

    ex:
    ```
    memorydb_node_type = "db.t4g.small"
    ```
  EOT
  type        = string
  default     = "db.t4g.small"
}

variable "memorydb_num_shards" {
  description = <<-EOT
    (Optional) The number of shards in the cluster.

    ex:
    ```
    memorydb_num_shards = 1
    ```
  EOT
  type        = number
  default     = 1
}

variable "memorydb_num_replicas_per_shard" {
  description = <<-EOT
    (Optional) The number of replicas per shard.

    ex:
    ```
    memorydb_num_replicas_per_shard = 2
    ```
  EOT
  type        = number
  default     = 2
}

variable "enable_memorydb_data_tiering" {
  description = <<-EOT
    (Optional) Determines if data tiering is enabled.

    ex:
    ```
    enable_memorydb_data_tiering = false
    ```
  EOT
  type        = string
  default     = false
}

variable "memorydb_sns_topic_arn" {
  description = <<-EOT
    (Optional) The ARN of the SNS topic to send MemoryDB events to.

    ex:
    ```
    memorydb_sns_topic_arn = "arn:aws:sns:us-east-1:123456789012:anyscale-memorydb-events"
    ```
  EOT
  type        = string
  default     = null
}

variable "memorydb_tls_enabled" {
  description = <<-EOT
    (Optional) Determines if TLS encryption is enabled.

    ex:
    ```
    memorydb_tls_enabled = true
    ```
  EOT
  type        = bool
  default     = true
}

# MemoryDB Snapshots
variable "memorydb_snapshot_retention_limit" {
  description = <<-EOT
    (Optional) The number of days for which MemoryDB retains automatic snapshots before deleting them.

    ex:
    ```
    snapshot_retention_limit = 7
    ```
  EOT
  type        = number
  default     = null
}

variable "memorydb_snapshot_window" {
  description = <<-EOT
    (Optional) The daily time range (in UTC) during which MemoryDB begins taking a daily snapshot of your shard.

    Please remember that the snapshot window and the maintenance window can not overlap.

    ex:
    ```
    memorydb_snapshot_window = "05:00-09:00"
    ```
  EOT
  type        = string
  default     = null
}

variable "memorydb_final_snapshot_name" {
  description = <<-EOT
    (Optional) The name of a final snapshot to be taken immediately before deleting the cluster.

    ex:
    ```
    memorydb_final_snapshot_name = "anyscale-memorydb-final-snapshot"
    ```
  EOT
  type        = string
  default     = null
  validation {
    condition     = var.memorydb_final_snapshot_name == null ? true : (can(regex("^[a-z0-9-]*$", var.memorydb_final_snapshot_name)))
    error_message = "The `memorydb_final_snapshot_name` variable must `null` or contain only lowercase alphanumeric characters and hyphens."
  }
}

#-------------------------
#- MemoryDB Parameter Group
variable "create_memorydb_parameter_group" {
  description = <<-EOT
    (Optional) Determines if a MemoryDB parameter group should be created.

    If `false`, the `existing_memorydb_parameter_group_name` variable must be set.

    ex:
    ```
    create_memorydb_parameter_group = true
    ```
  EOT
  type        = bool
  default     = true
}

variable "existing_memorydb_parameter_group_name" {
  description = <<-EOT
    (Optional) The name of an existing MemoryDB parameter group to use.

    If not provided, `create_memorydb_parameter_group` must be set to `true` and a new MemoryDB parameter group will be created.
    If this is provided, `create_memorydb_parameter_group` must be set to `false`.

    ex:
    ```
    existing_memorydb_parameter_group_name = "anyscale-memorydb-parameter-group"
    ```
  EOT
  type        = string
  default     = null
}

variable "memorydb_parameter_group_name" {
  description = <<-EOT
    (Optional) Name for the MemoryDB parameter group.

    If left `null`, will default to `anyscale_memorydb_name_prefix`.
    If provided, overrides the `anyscale_memorydb_name_prefix` variable.

    ex:
    ```
    memorydb_parameter_group_name = "anyscale-memorydb-parameter-group"
    ```
  EOT
  type        = string
  default     = null
  validation {
    condition     = var.memorydb_parameter_group_name == null ? true : (can(regex("^[a-z0-9-]*$", var.memorydb_parameter_group_name)))
    error_message = "The `memorydb_parameter_group_name` variable must `null` or contain only lowercase alphanumeric characters and hyphens."
  }
}

variable "memorydb_parameter_group_name_prefix" {
  description = <<-EOT
    (Optional) Name prefix for the MemoryDB parameter group.

    If `memorydb_parameter_group_name` is provided, it will override this variable.
    Default is `null` but is set to `anyscale-mdb-pg-` in a local variable.

    ex:
    ```
    memorydb_parameter_group_name_prefix = "anyscale-mdb-pg-"
    ```
  EOT
  type        = string
  default     = null
  validation {
    condition     = var.memorydb_parameter_group_name_prefix == null ? true : (can(regex("^[a-z0-9-]*$", var.memorydb_parameter_group_name_prefix)))
    error_message = "The `memorydb_parameter_group_name_prefix` variable must `null` or contain only lowercase alphanumeric characters and hyphens."
  }
}

variable "memorydb_parameter_group_description" {
  description = <<-EOT
    (Optional) A description of the MemoryDB parameter group.

    This should be a meaningful description of the MemoryDB parameter group.

    ex:
    ```
    memorydb_parameter_group_description = "Anyscale MemoryDB Parameter Group for Anyscale Services"
    ```
  EOT
  type        = string
  default     = "Anyscale MemoryDB Parameter Group for Anyscale Services"
}

variable "memorydb_parameter_group_family" {
  description = <<-EOT
    (Optional) The family of the MemoryDB parameter group.

    The following are the supported families:

    * `memorydb_redis7`
    * `memorydb_redis6`
    * `memorydb_redis5`

    ex:
    ```
    memorydb_parameter_group_family = "memorydb_redis7"
    ```
  EOT
  type        = string
  default     = "memorydb_redis7"
  validation {
    condition = (
      var.memorydb_parameter_group_family == "memorydb_redis7" ||
      var.memorydb_parameter_group_family == "memorydb_redis6" ||
      var.memorydb_parameter_group_family == "memorydb_redis5"
    )
    error_message = "The memorydb_parameter_group_family value must be either \"memorydb_redis7\", \"memorydb_redis6\", or \"memorydb_redis5\"."
  }
}

variable "memorydb_parameter_group_parameters" {
  description = <<-EOT
    (Optional) A list of parameters to be added to the MemoryDB parameter group.

    ex:
    ```
    memorydb_parameter_group_parameters = [
      {
        name  = "maxmemory-policy"
        value = "allkeys-lru"
      },
      {
        name  = "activedefrag"
        value = "yes"
      }
    ]
    ```
  EOT
  type = list(object({
    name  = string
    value = string
  }))
  default = [
    {
      name  = "maxmemory-policy"
      value = "allkeys-lru"
    }
  ]
}

variable "memorydb_parameter_group_tags" {
  description = <<-EOT
    (Optional) A map of tags to be added to the MemoryDB parameter group.

    Duplicate tags in `tags` and `memorydb_parameter_group_tags` will be overwritten.

    ex:
    ```
    memorydb_parameter_group_tags = {
      application = "Anyscale",
      environment = "prod"
    }
    ```
  EOT
  type        = map(string)
  default     = {}
}

#-------------------------
# MemoryDB ACL Configuration
variable "create_memorydb_acl" {
  description = <<-EOT
    (Optional) Determines if a MemoryDB ACL should be created.

    If `false`, the `existing_memorydb_acl_name` variable must be set.

    ex:
    ```
    create_memorydb_acl = true
    ```
  EOT
  type        = bool
  default     = false
}

variable "existing_memorydb_acl_name" {
  description = <<-EOT
    (Optional) The name of an existing MemoryDB ACL to use.

    If not provided, `create_memorydb_acl` must be set to `true` and a new MemoryDB ACL will be created.
    If this is provided, `create_memorydb_acl` must be set to `false`.

    ex:
    ```
    existing_memorydb_acl_name = "open-access"
    ```
  EOT
  type        = string
  default     = "open-access"
}

variable "memorydb_acl_name" {
  description = <<-EOT
    (Optional) Name for the MemoryDB ACL.

    If left `null`, will default to `anyscale_memorydb_name_prefix`.
    If provided, overrides the `anyscale_memorydb_name_prefix` variable.

    ex:
    ```
    memorydb_acl_name = "anyscale-memorydb-acl"
    ```
  EOT
  type        = string
  default     = null
  validation {
    condition     = var.memorydb_acl_name == null ? true : (can(regex("^[a-z0-9-]*$", var.memorydb_acl_name)))
    error_message = "The `memorydb_acl_name` variable must `null` or contain only lowercase alphanumeric characters and hyphens."
  }
}

variable "memorydb_acl_name_prefix" {
  description = <<-EOT
    (Optional) Name prefix for the MemoryDB ACL.

    If `memorydb_acl_name` is provided, it will override this variable.
    Default is `null` but is set to `anyscale-mdb-acl-` in a local variable.

    ex:
    ```
    memorydb_acl_name_prefix = "anyscale-mdb-acl-"
    ```
  EOT
  type        = string
  default     = null
  validation {
    condition     = var.memorydb_acl_name_prefix == null ? true : (can(regex("^[a-z0-9-]*$", var.memorydb_acl_name_prefix)))
    error_message = "The `memorydb_acl_name_prefix` variable must `null` or contain only lowercase alphanumeric characters and hyphens."
  }
}

variable "memorydb_acl_tags" {
  description = <<-EOT
    (Optional) A map of tags to be added to the MemoryDB ACL.

    Duplicate tags in `tags` and `memorydb_acl_tags` will be overwritten.

    ex:
    ```
    memorydb_acl_tags = {
      application = "Anyscale",
      environment = "prod"
    }
    ```
  EOT
  type        = map(string)
  default     = {}
}

variable "memorydb_acl_user_names" {
  description = <<-EOT
    (Optional) A list of user names to be added to the MemoryDB ACL.

    ex:
    ```
    memorydb_acl_user_names = [
      "admin",
      "readonly"
    ]
    ```
  EOT
  type        = list(string)
  default     = []
}

#-------------------------
# MemoryDB Users
variable "create_memorydb_users" {
  description = <<-EOT
    (Optional) Determines if MemoryDB users should be created.

    ex:
    ```
    create_memorydb_users = true
    ```
  EOT
  type        = bool
  default     = false
}

variable "memorydb_users" {
  description = <<-EOT
    (Optional) A map of MemoryDB users to be created.

    ex:
    ```
    memorydb_users = {
      admin = {
        user_name     = "admin-user"
        access_string = "on ~* &* +@all"
        passwords     = [random_password.password["admin"].result]
        tags          = { user = "admin" }
      }
      readonly = {
        user_name     = "readonly-user"
        access_string = "on ~* &* -@all +@read"
        passwords     = [random_password.password["readonly"].result]
        tags          = { user = "readonly" }
      }
    }
  EOT
  type        = map(any)
  default     = {}
}

#-------------------------
# MemoryDB Subnet Groups
variable "create_memorydb_subnet_group" {
  description = <<-EOT
    (Optional) Determines if a MemoryDB subnet group should be created.

    If `false`, the `existing_memorydb_subnet_group_name` variable must be set.

    ex:
    ```
    create_memorydb_subnet_group = true
    ```
  EOT
  type        = bool
  default     = true
}

variable "existing_memorydb_subnet_group_name" {
  description = <<-EOT
    (Optional) The name of an existing MemoryDB subnet group to use.

    If not provided, `create_memorydb_subnet_group` must be set to `true` and a new MemoryDB subnet group will be created.
    If this is provided, `create_memorydb_subnet_group` must be set to `false`.

    ex:
    ```
    existing_memorydb_subnet_group_name = "anyscale-memorydb-subnet-group"
    ```
  EOT
  type        = string
  default     = null
}

variable "memorydb_subnet_group_name" {
  description = <<-EOT
    (Optional) Name for the MemoryDB subnet group.

    If left `null`, will default to `anyscale_memorydb_name_prefix`.
    If provided, overrides the `anyscale_memorydb_name_prefix` variable.

    ex:
    ```
    memorydb_subnet_group_name = "anyscale-mdb-sg"
    ```
  EOT
  type        = string
  default     = null
  validation {
    condition     = var.memorydb_subnet_group_name == null ? true : (can(regex("^[a-z0-9-]*$", var.memorydb_subnet_group_name)))
    error_message = "The `memorydb_subnet_group_name` variable must `null` or contain only lowercase alphanumeric characters and hyphens."
  }
}

variable "memorydb_subnet_group_name_prefix" {
  description = <<-EOT
    (Optional) Name prefix for the MemoryDB subnet group.

    If `memorydb_subnet_group_name` is provided, it will override this variable.
    Default is `null` but is set to `anyscale-mdb-sg-` in a local variable.

    ex:
    ```
    memorydb_subnet_group_name_prefix = "anyscale-mdb-sg-"
    ```
  EOT
  type        = string
  default     = null
  validation {
    condition     = var.memorydb_subnet_group_name_prefix == null ? true : (can(regex("^[a-z0-9-]*$", var.memorydb_subnet_group_name_prefix)))
    error_message = "The `memorydb_subnet_group_name_prefix` variable must `null` or contain only lowercase alphanumeric characters and hyphens."
  }
}

variable "memorydb_subnet_group_description" {
  description = <<-EOT
    (Optional) A description of the MemoryDB subnet group.

    This should be a meaningful description of the MemoryDB subnet group.

    ex:
    ```
    memorydb_subnet_group_description = "Anyscale MemoryDB Subnet Group for Anyscale Services"
    ```
  EOT
  type        = string
  default     = "Anyscale MemoryDB Subnet Group for Anyscale Services"
}

variable "memorydb_subnet_group_tags" {
  description = <<-EOT
    (Optional) A map of tags to be added to the MemoryDB subnet group.

    Duplicate tags in `tags` and `memorydb_subnet_group_tags` will be overwritten.

    ex:
    ```
    memorydb_subnet_group_tags = {
      application = "Anyscale",
      environment = "prod"
    }
    ```
  EOT
  type        = map(string)
  default     = {}
}
