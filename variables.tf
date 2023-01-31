# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# These variables must be set when using this module.
# ------------------------------------------------------------------------------
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

variable "cloud_provider" {
  description = "(Required) Which cloud provider would you like to run this module on? Valid options are `aws` or `gcp`. Default is `aws`."
  type        = string
  default     = "aws"
  validation {
    condition = (
      var.cloud_provider == "aws" || var.cloud_provider == "gcp"
    )
    error_message = "The cloud_provider variable only allows `aws` or `gcp`"
  }
}

variable "security_group_ingress_allow_access_from_cidr_range" {
  description = <<-EOT
    (Required) Comma delimited string of IPv4 CIDR range to allow access to anyscale resources.
    This should be the list of CIDR ranges that have access to the clusters. If using Anyscale v1,
    this should be public IPs. If using Anyscale v2, public or private IPs are supported. SSH and HTTPs
    ports will be opened to these CIDR ranges.
    ex: "10.0.1.0/24,24.1.24.24/32"
  EOT
  type        = string
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES
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
  default     = {}
}

#--------------------------------------------
# VPC Variables
#--------------------------------------------
variable "existing_vpc_id" {
  description = "(Optional) An existing VPC ID. If provided, this will skip creating resources with the Anyscale VPC module. Subnet IDs is also required if this is provided. Default is `null`."
  type        = string
  default     = null
}
variable "existing_subnet_ids" {
  description = "(Optional) Existing subnet IDs to create Anyscale resources in. If provided, this will skip creating resources with the Anyscale VPC module. VPC ID is also required is this is provided. Default is an empty list."
  type        = list(string)
  default     = []
}
variable "anyscale_vpc_name" {
  description = "(Optional) VPC name. Will default to `vpc_<anyscale_cloud_id>`."
  type        = string
  default     = null
}
variable "anyscale_vpc_cidr_block" {
  description = "(Optional) The IPv4 CIDR block for the VPC. CIDR can be explicitly set or it can be derived from IPAM using `ipv4_netmask_length` & `ipv4_ipam_pool_id`. Default is `10.0.0.0/16`"
  type        = string
  default     = "10.0.0.0/16"
}
variable "anyscale_vpc_public_subnets" {
  description = "(Optional) A list of public subnets inside the VPC. Default is an empty list."
  type        = list(string)
  default     = []
}
variable "anyscale_vpc_private_subnets" {
  description = "(Optional) A list of private subnets inside the VPC. Default is an empty list."
  type        = list(string)
  default     = []
}

#--------------------------------------------
# IAM Variables
#--------------------------------------------
variable "anyscale_iam_access_role_name" {
  description = <<-EOT
    (Optional, forces creation of new resource)
    The name of the Anyscale IAM access role.
    If left `null`, will default to anyscale_iam_access_role_name_prefix.
    If provided, overrides the anyscale_iam_access_role_name_prefix variable.
    Default is `null`.
  EOT
  type        = string
  default     = null
}

variable "anyscale_iam_access_role_name_prefix" {
  description = <<-EOT
    (Optional, forces creation of new resource)
    The prefix for the Anyscale IAM access role.
    The variable, anyscale_iam_access_role_name, will override this variable.
    Default is `anyscale-iam-role-`.
  EOT
  type        = string
  default     = "anyscale-iam-role-"
}

variable "anyscale_iam_cluster_node_role_name" {
  description = <<-EOT
    (Optional, forces creation of new resource)
    The name of the Anyscale IAM cluster node role.
    If left `null`, will default to anyscale_iam_access_role_name_prefix.
    Default is `null`.
  EOT
  type        = string
  default     = null
}
variable "anyscale_iam_cluster_node_role_name_prefix" {
  description = <<-EOT
    (Optional, forces creation of new resource)
    The prefix of the Anyscale Cluster Node IAM role.
    The variable, anyscale_iam_cluster_node_role_name, will override this variable.
    Default is `anyscale-cluster-node-`.
  EOT
  type        = string
  default     = "anyscale-cluster-node-"
}

#--------------------------------------------
# Security Group Variables
#--------------------------------------------
variable "security_group_name" {
  description = <<-EOT
    (Optional) The name for the security group. If provided, overrides the security_group_name_prefix.
    Default is `null`.
  EOT
  type        = string
  default     = null
}

variable "security_group_name_prefix" {
  description = "(Optional) The name prefix for the security group. Conflicts with security_group_name. Default is `anyscale-security-group-`."
  type        = string
  default     = "anyscale-security-group-"
}
variable "security_group_create_anyscale_public_ingress" {
  type        = bool
  description = "(Optional) Determines if public ingress rules should be created. Default is `false`."
  default     = false
}

# ex:
# ingress_with_existing_security_groups_map = [
#   {
#     rule              = "https-443-tcp"
#     security_group_id = "sg-0123456789001ab8e"
#   },
#   {
#     rule              = "ssh-tcp"
#     security_group_id = "sg-0123456789001ab8e"
#   }
# ]
variable "security_group_ingress_with_existing_security_groups_map" {
  type        = list(map(string))
  description = "(Optional) List of security groups and rules to allow ingress from. Default is an empty list."
  default     = []
}

# ex:
# ingress_from_cidr_map = [
#   {
#     rule        = "https-443-tcp"
#     cidr_blocks = "10.100.10.10/32"
#   },
#   { rule = "nfs-tcp" },
#   {
#     rule        = "ssh-tcp"
#     cidr_blocks = "10.100.10.10/32"
#   },
#   {
#     from_port   = 10
#     to_port     = 20
#     protocol    = 6
#     description = "Service name is TEST"
#     cidr_blocks = "10.100.10.10/32"
#   }
# ]
variable "security_group_override_ingress_from_cidr_map" {
  type        = list(map(string))
  description = <<-EOT
    (Optional) List of ingress rules to create with cidr ranges.
    If this variable is provided/populated, the default rules will not be created. At a minimum, https and ssh need
    to be allowed from a IPv4 CIDR block that allows access for the users who are using Anyscale.
    Default is an empty list.
  EOT
  default     = []
}

#--------------------------------------------
# EFS Variables
#--------------------------------------------
variable "efs_name" {
  description = <<-EOT
    (Optional) Elastic file system name. Will default to `efs_anyscale` if this var `null` and anyscale_cloud_id is also `null`.
    Default is `null`.
  EOT
  type        = string
  default     = null
}

variable "efs_creation_token" {
  description = <<-EOT
    (Optional) A unique token used as reference when creating the Elastic File System to ensure idempotent file system creation.
    Default is `null` which forces Terraform to generate it.
  EOT
  type        = string
  default     = null
}

variable "efs_lifecycle_transition_to_ia" {
  description = <<-EOT
    (Optional) Indicates how long it takes to transition files to Infrequent Access storage class.
    No value, or an empty list, means never.
    Must either be an empty list or one of "AFTER_7_DAYS", "AFTER_14_DAYS", "AFTER_30_DAYS", "AFTER_60_DAYS", "AFTER_90_DAYS".
    Default is `AFTER_60_DAYS` which will transition to IA after 60 days.
  EOT
  type        = list(string)
  default     = ["AFTER_60_DAYS"]
  validation {
    condition = (
      length(var.efs_lifecycle_transition_to_ia) == 1 ? contains(["AFTER_7_DAYS", "AFTER_14_DAYS", "AFTER_30_DAYS", "AFTER_60_DAYS", "AFTER_90_DAYS"], var.efs_lifecycle_transition_to_ia[0]) : length(var.efs_lifecycle_transition_to_ia) == 0
    )
    error_message = "`efs_lifecycle_transition_to_ia` must either be empty list or one of \"AFTER_7_DAYS\", \"AFTER_14_DAYS\", \"AFTER_30_DAYS\", \"AFTER_60_DAYS\", \"AFTER_90_DAYS\"."
  }
}

variable "efs_lifecycle_transition_to_primary_storage_class" {
  type        = list(string)
  description = <<-EOT
    (Optional) Indicates the policy used to transition a file from Infrequent Access (IA) storage to primary storage.
    Must either be an empty list or `AFTER_1_ACCESS`.
    Default is `AFTER_1_ACCESS`.
  EOT
  default     = ["AFTER_1_ACCESS"]
  validation {
    condition = (
      length(var.efs_lifecycle_transition_to_primary_storage_class) == 1 ? contains(["AFTER_1_ACCESS"], var.efs_lifecycle_transition_to_primary_storage_class[0]) : length(var.efs_lifecycle_transition_to_primary_storage_class) == 0
    )
    error_message = "Var `efs_lifecycle_transition_to_primary_storage_class` must either be empty list or \"AFTER_1_ACCESS\"."
  }
}

# S3 Variables
variable "anyscale_s3_bucket_name" {
  description = <<-EOT
    (Optional - forces new resource)
    The name of the bucket used to store Anyscale related logs and other shared resources.
    If left `null`, will default to anyscale_s3_bucket_prefix.
    If provided, overrides the anyscale_s3_bucket_prefix variable.
    Conflicts with anyscale_bucket_prefix. Default is `null`.
  EOT
  type        = string
  default     = null
}

variable "anyscale_s3_bucket_prefix" {
  description = <<-EOT
    (Optional - forces new resource)
    Creates a unique bucket name beginning with the specified prefix.
    If `anyscale_s3_bucket_name` is provided, it will override this variable.
    Default is `anyscale-`.
  EOT
  type        = string
  default     = "anyscale-"
}
