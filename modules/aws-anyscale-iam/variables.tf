# ------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables must be set when using this module.
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These variables have defaults, but may be overridden.
# ------------------------------------------------------------------------------
variable "anyscale_cloud_id" {
  description = "(Required) Anyscale Cloud ID"
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
  description = "(Optional) Determines whether to create the resources inside this module. Default is `true`."
  type        = bool
  default     = true
}

variable "tags" {
  description = "(Optional) A map of tags to all resources that accept tags. Default is an empty map."
  type        = map(string)
  default     = {}
}

#-------------------
# Anyscale Cross Acct
#   Access Role
#-------------------
variable "create_anyscale_access_role" {
  description = "(Optional) Determines whether to create the Anyscale access role. Default is `true`."
  type        = bool
  default     = true
}
variable "anyscale_access_role_name" {
  description = "(Optional, forces creation of new resource) The name of the Anyscale IAM access role. Conflicts with anyscale_access_role_name_prefix. Default is `null`."
  type        = string
  default     = null
}

variable "anyscale_access_role_name_prefix" {
  description = "(Optional, forces creation of new resource) The prefix of the Anyscale IAM access role. Conflicts with anyscale_access_role_name. Default is `anyscale-iam-role-`."
  type        = string
  default     = "anyscale-iam-role-"
}

variable "anyscale_access_role_path" {
  description = "(Optional) The path to the IAM role. Default is `/`"
  type        = string
  default     = "/"
}

variable "anyscale_access_role_description" {
  description = "(Optional) IAM Role description. Default is `null`."
  type        = string
  default     = null
}

variable "role_permissions_boundary_arn" {
  description = "(Optional) Permissions boundary ARN to use for IAM role. Default is `null`."
  type        = string
  default     = null
}

variable "anyscale_trusted_role_arns" {
  description = "(Optional) ARNs of AWS entities who can assume these roles. Default is the AWS account for Anyscale."
  type        = list(string)
  default     = ["arn:aws:iam::525325868955:root"]
}
variable "anyscale_trusted_role_sts_externalid" {
  description = "(Optional) STS ExternalId condition values to use with a role. Default is an empty list."
  type        = any
  default     = []
}

variable "create_anyscale_access_steadystate_policy" {
  description = "(Optional) Deterimines if the Anyscale IAM steadystate policy is created. Default is `true`."
  type        = bool
  default     = true
}

variable "anyscale_access_steadystate_policy_name" {
  description = "(Optional) Name for the Anyscale default steady state IAM policy. Will use policy_name_prefix if this is set to `null`. Default is `null`."
  type        = string
  default     = null
}

variable "anyscale_access_steadystate_policy_path" {
  description = "(Optional) Path for the Anyscale default steady steate IAM policy. Defualt is `/`."
  type        = string
  default     = "/"
}

variable "anyscale_access_steadystate_policy_prefix" {
  description = "(Optional) Name prefix for the Anyscale default steady state IAM policy. Conflicts with anyscale_access_steadystate_policy_name. Default is `anyscale-steady_state-`."
  type        = string
  default     = "anyscale-steady_state-"
}

variable "anyscale_access_steadystate_policy_description" {
  description = "(Optional) Anyscale steady state IAM policy description. Default is `Anyscale Steady State IAM Policy`"
  type        = string
  default     = "Anyscale Steady State IAM Policy"
}

# Services v2 Policy
variable "create_anyscale_access_servicesv2_policy" {
  description = "(Optional) Determines if the IAM policy for Services v2 is created. Default is `true`."
  type        = bool
  default     = true
}
variable "anyscale_access_servicesv2_policy_name" {
  description = "(Optional) Name for the Anyscale Services v2 Policy. Will use policy_name_prefix if this is set to `null`. Default is `null`."
  type        = string
  default     = null
}
variable "anyscale_access_servicesv2_policy_path" {
  description = "(Optional) Path for the Anyscale Services v2 IAM policy. Default is `/`."
  type        = string
  default     = "/"
}
variable "anyscale_access_servicesv2_policy_prefix" {
  description = "(Optional) Name prefix for the Anyscale default Services v2 policy. Conflicts with anyscale_access_servicesv2_policy_name. Default is `anyscale-servicesv2-`."
  type        = string
  default     = "anyscale-servicesv2-"
}
variable "anyscale_access_servicesv2_policy_description" {
  description = "(Optional) Anyscale Services v2 policy description. Default is `Anyscale IAM policy for Services v2 - assigned to the Anyscale Access role.`"
  type        = string
  default     = "Anyscale IAM policy for Services v2 - assigned to the Anyscale Access role."
}

# Custom Policy
variable "anyscale_custom_policy_name" {
  description = "(Optional) Name for an Anyscale custom IAM policy. Default is `null`."
  type        = string
  default     = null
}

variable "anyscale_custom_policy_name_prefix" {
  description = "(Optional) Name prefix for the Anyscale custom IAM policy. Default is `anyscale-iam-role-custom-`."
  type        = string
  default     = "anyscale-iam-role-custom-"
}

variable "anyscale_custom_policy_path" {
  description = "(Optional) Path of the Anyscale custom IAM policy. Default is `/`."
  type        = string
  default     = "/"
}

variable "anyscale_custom_policy_description" {
  description = "(Optional) Anyscale IAM custom policy description. Default is `Anyscale IAM Policy`."
  type        = string
  default     = "Anyscale IAM Policy"
}

variable "anyscale_custom_policy" {
  description = "(Optional) Anyscale custom IAM policy. Default is `null`."
  type        = string
  default     = null
}

variable "enable_ec2_container_registry_readonly_access" {
  description = "(Optional) Determines if the Amazon EC2 container registry read-only access policy is attached. If false, an alternative must be specified in anyscale_custom_policy. Default is `true`."
  type        = string
  default     = true
}
variable "anyscale_access_managed_policy_arns" {
  description = "(Optional) List of IAM custom or managed policy ARNs to attach to the role. Default is an empty list."
  type        = list(string)
  default     = []
}

# ------------------
# Cluster Node Role
#  & Instance Profile
# ------------------
variable "create_cluster_node_instance_profile" {
  description = "(Optional) Determines whether to create an instance profile role. Default is `true`."
  type        = bool
  default     = true
}

variable "anyscale_cluster_node_role_name" {
  description = "(Optional, forces creation of new resource) The name of the Anyscale IAM cluster node role. Default is `null`."
  type        = string
  default     = null
}

variable "anyscale_cluster_node_role_name_prefix" {
  description = "(Optional, forces creation of new resource) The prefix of the Anyscale Cluster Node IAM role. Default is `anyscale-cluster-node-`."
  type        = string
  default     = "anyscale-cluster-node-"
}

variable "anyscale_cluster_node_role_path" {
  description = "(Optional) The path to the Cluster Node IAM role. Default is `/`."
  type        = string
  default     = "/"
}

variable "anyscale_cluster_node_role_description" {
  description = "(Optional) IAM Role description. Default is `null`."
  type        = string
  default     = null
}

# Cluster Node Custom Policy
variable "anyscale_cluster_node_custom_policy_name" {
  description = "(Optional) Name for the Anyscale cluster node custom IAM policy. Default is `null`."
  type        = string
  default     = null
}

variable "anyscale_cluster_node_custom_policy_prefix" {
  description = "(Optional) Name prefix for the Anyscale cluster node custom IAM policy. Default is `anyscale-iam-role-custom-`."
  type        = string
  default     = "anyscale-cluster-node-custom-"
}

variable "anyscale_cluster_node_custom_policy_path" {
  description = "(Optional) Path of the Anyscale cluster node custom IAM policy. Default is `/`."
  type        = string
  default     = "/"
}

variable "anyscale_cluster_node_custom_policy_description" {
  description = "(Optional) Anyscale IAM cluster node custom policy description. Default is `Anyscale Cluster Node IAM Policy`."
  type        = string
  default     = "Anyscale Cluster Node IAM Policy"
}

variable "anyscale_cluster_node_custom_policy" {
  description = "(Optional) Anyscale cluster node custom IAM policy. Default is `null`."
  type        = string
  default     = null
}

variable "anyscale_cluster_node_managed_policy_arns" {
  description = "(Optional) List of IAM custom or managed policy ARNs to attach to the role. Default is an empty list."
  type        = list(string)
  default     = []
}

# S3 Bucket Access Related
variable "create_iam_s3_policy" {
  description = "(Optional) Determines whether to create the S3 Access Policy for IAM roles. Requires anyscale_s3_bucket_arn (below). Default is `true`."
  type        = bool
  default     = true
}
variable "anyscale_s3_bucket_arn" {
  description = <<-EOT
    (Optional) The S3 Bucket arn that the IAM Roles need access to.
    If not provided, make sure to set `create_iam_s3_policy` to `false` otherwise this will throw an error.
    Default is `null`.
  EOT
  type        = string
  default     = null
}

variable "anyscale_iam_s3_policy_name" {
  description = "(Optional) Name for the Anyscale S3 access IAM policy. Default is `null`."
  type        = string
  default     = null
}

variable "anyscale_iam_s3_policy_name_prefix" {
  description = "(Optional) Name prefix for the Anyscale S3 access IAM policy. Default is `anyscale-iam-s3-`."
  type        = string
  default     = "anyscale-iam-s3-"
}

variable "anyscale_iam_s3_policy_path" {
  description = "(Optional) Path of the Anyscale S3 access IAM policy. Default is `/`."
  type        = string
  default     = "/"
}

variable "anyscale_iam_s3_policy_description" {
  description = "(Optional) Anyscale S3 access IAM policy description. Default is `Anyscale S3 Access IAM Policy`."
  type        = string
  default     = "Anyscale S3 Access IAM Policy"
}
