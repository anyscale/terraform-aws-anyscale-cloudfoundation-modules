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
  description = <<-EOT
    (Optional)
    A map of default tags to be added to all resources that accept tags.
    Resource dependent tags will be appended to this list.
    ex:
    tags = {
      application = "Anyscale",
      environment = "prod"
    }
    Default is an empty map.
  EOT
  type        = map(string)
  default     = {}
}

variable "common_prefix" {
  description = <<-EOT
    (Optional)
    A common prefix to add to resources created (where prefixes are allowed).
    If paired with `use_common_name`, this will apply to all resources.
    If this is not paired with `use_common_name`, this applies to:
      - S3 Buckets
      - IAM Resources
      - Security Groups
    Resource specific prefixes override this variable.
    Max length is 30 characters.
    Default is `null`
  EOT
  type        = string
  default     = null
  validation {
    condition     = var.common_prefix == null || try(length(var.common_prefix) <= 30, false)
    error_message = "common_prefix must either be `null` or less than 30 characters."
  }
}

variable "use_common_name" {
  description = <<-EOT
    (Optional)
    Determines if a standard name should be used across all resources.
    If set to true and `common_prefix` is also provided, the `common_prefix` will be used prefixed to a common name.
    If set to true and `common_prefix` is not provided, the prefix will be `anyscale-`
    Default is `false`
  EOT
  type        = bool
  default     = false
}

#--------------------------------------------
# VPC Variables
#--------------------------------------------
variable "existing_vpc_id" {
  description = "(Optional) An existing VPC ID. If provided, this will skip creating resources with the Anyscale VPC module. Subnet IDs is also required if this is provided. Default is `null`."
  type        = string
  default     = null
}
variable "existing_vpc_subnet_ids" {
  description = "(Optional) Existing subnet IDs to create Anyscale resources in. If provided, this will skip creating resources with the Anyscale VPC module. VPC ID is also required is this is provided. Default is an empty list."
  type        = list(string)
  default     = []
}
variable "existing_vpc_route_table_ids" {
  description = <<-EOT
    (Optional)
    Existing VPC Route Table IDs.
    If provided, this will map new subnets to these route table IDs. If no new subnets are created, these route tables will be used to create VPC Endpoint(s).
  EOT
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

variable "anyscale_vpc_tags" {
  description = <<-EOT
    (Optional)
    A map of tags for VPC resources.
    Duplicate tags found in the "tags" variable will get duplicated on the resource.
    ex:
    anyscale_vpc_tags = {
      "purpose" : "networking",
      "criticality" : "critical"
    }
    Default is an empty map.
  EOT
  type        = map(string)
  default     = {}
}

variable "anyscale_gateway_vpc_endpoints" {
  description = <<-EOT
    A map of Gateway VPC Endpoints to provision into the VPC. This is a map of objects with the following attributes:
    - `name`: Short service name (either "s3" or "dynamodb")
    - `policy` = A policy (as JSON string) to attach to the endpoint that controls access to the service. May be `null` for full access.
    See the submodule variable for a full example.
    It is Anyscale's recommendation to have an S3 VPC Endpoint to minimize S3 costs and maximize S3 performance.
    Set to an empty map `{}` to skip creating VPC Endpoints.
    Default is S3 with an empty (full access) policy.
  EOT
  type = map(object({
    name   = string
    policy = string
  }))
  default = {
    "s3" = {
      name   = "s3"
      policy = null
    }
  }
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
    If `anyscale_iam_access_role_name_prefix` is provided, it will override this variable.
    The variable `general_prefix` is a fall-back prefix if this is not provided.
    Default is `null` but is set to `anyscale-iam-role-` in a local variable.
  EOT
  type        = string
  default     = null
}

variable "anyscale_access_steadystate_policy_name" {
  description = <<-EOT
    (Optional)
    Name for the Anyscale default steady state IAM policy.
    If left `null`, will default to `anyscale_access_steadystate_policy_prefix`
    If provided, overrides the `anyscale_access_steadystate_policy_prefix` variable.
    Default is `null`.
  EOT
  type        = string
  default     = null
}
variable "anyscale_access_steadystate_policy_prefix" {
  description = <<-EOT
    (Optional)
    Name prefix for the Anyscale default steady state IAM policy.
    If `anyscale_access_steadystate_policy_name` is provided, it will override this variable.
    The variable `general_prefix` is a fall-back prefix if this is not provided.
    Default is `null` but is set to `anyscale-steady_state-` in a local variable.
  EOT
  type        = string
  default     = null
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
    If `anyscale_iam_cluster_node_role_name` is provided, it will override this variable.
    The variable `general_prefix` is a fall-back prefix if this is not provided.
    Default is `null` but is set to `anyscale-cluster-node-` in a local variable.
  EOT
  type        = string
  default     = null
}

variable "anyscale_iam_tags" {
  description = <<-EOT
    (Optional)
    A map of tags for IAM resources.
    Duplicate tags found in the "tags" variable will get duplicated on the resource.
    ex:
    anyscale_iam_tags = {
      "purpose" : "iam",
      "criticality" : "critical"
    }
    Default is an empty map.
  EOT
  type        = map(string)
  default     = {}
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
  description = <<-EOT
    (Optional)
    The name prefix for the security group.
    If `security_group_name` is provided, it will override this variable.
    The variable `general_prefix` is a fall-back prefix if this is not provided.

    Default is `null` but is set to `anyscale-security-group-` in a local variable.
  EOT
  type        = string
  default     = null
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

variable "anyscale_securitygroup_tags" {
  description = <<-EOT
    (Optional)
    A map of tags for Security Group resources.
    Duplicate tags found in the "tags" variable will get duplicated on the resource.
    ex:
    anyscale_iam_tags = {
      "purpose" : "security",
      "criticality" : "critical"
    }
    Default is an empty map.
  EOT
  type        = map(string)
  default     = {}
}

#--------------------------------------------
# EFS Variables
#--------------------------------------------
variable "anyscale_efs_name" {
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

variable "anyscale_efs_tags" {
  description = <<-EOT
    (Optional)
    A map of tags for EFS resources.
    Duplicate tags found in the "tags" variable will get duplicated on the resource.
    ex:
    anyscale_iam_tags = {
      "purpose" : "storage",
      "criticality" : "critical"
    }
    Default is an empty map.
  EOT
  type        = map(string)
  default     = {}
}

#--------------------------------------------
# S3 Variables
#--------------------------------------------
variable "existing_s3_bucket_arn" {
  description = <<-EOT
    (Optional)
    The name of an existing S3 bucket that you'd like to use.
    Please make sure that it meets the minimum requirements for Anyscale including:
      - Bucket Policy
      - CORS Policy
      - Encryption configuration
    Default is `null`
  EOT
  type        = string
  default     = null
}

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
    The variable `general_prefix` is a fall-back prefix if this is not provided.
    Default is `null` but is set to `anyscale-` in a local variable.
  EOT
  type        = string
  default     = null
}

variable "anyscale_s3_server_side_encryption" {
  description = <<-EOT
    (Optional)
    Configuration to enforce server side encryption (KMS or AES256).
    If you are using KMS, you must proivde the KMS Key ID.
    ex using kms:
    apply_server_side_encryption_by_default = {
      kms_master_key_id = "1234abcd-12ab-34cd-56ef-1234567890ab"
      sse_algorithm     = "aws:kms"
    }
    Default is `{ sse_algorithm = "AES256" }`
  EOT
  type        = map(string)
  default = {
    sse_algorithm = "AES256"
  }
}

variable "anyscale_s3_force_destroy" {
  description = <<-EOT
    (Optional)
    Set to true to delete all objects from the bucket so that the bucket can be destroyed without error.
    If set to true and bucket is destroyed, objects are not recoverable.
    Default is `false`.
    Note: With this default, you need to empty the bucket if there are objects before `terraform destroy` can be completed succesfully.
  EOT
  type        = bool
  default     = false
}

# S3 Bucket Policy Variables
# ex policy:
# data "aws_iam_policy_document" "bucket_policy" {
#  statement {
#     principals {
#       type        = "AWS"
#       identifiers = [aws_iam_role.this.arn]
#     }
#
#    actions = [
#      "s3:ListBucket",
#    ]
#
#    resources = [
#      "module.aws_anyscale_s3.s3_bucket_arn,
#    ]
#  }
# }
# anyscale_custom_s3_policy = data.aws_iam_policy_document.bucket_policy.json
variable "anyscale_custom_s3_policy" {
  description = <<-EOT
    (Optional)
    A valid bucket policy in JSON. This will be an additional S3 bucket policy to the required Anyscale policy.
    For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide.
    And for more additional examples, please look at the s3-policy sub-module examples folder.
    Default is `null`.
  EOT
  type        = string
  default     = null
}

variable "anyscale_s3_tags" {
  description = <<-EOT
    (Optional)
    A map of tags for S3 resources.
    Duplicate tags found in the "tags" variable will get duplicated on the resource.
    ex:
    anyscale_iam_tags = {
      "purpose" : "storage",
      "criticality" : "critical"
    }
    Default is an empty map.
  EOT
  type        = map(string)
  default     = {}
}
