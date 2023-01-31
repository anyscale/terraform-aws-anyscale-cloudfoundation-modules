# ------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables must be set when using this module.
# ------------------------------------------------------------------------------
variable "vpc_id" {
  description = "(Required) The ID of the VPC where the Security Group needs to be created."
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

variable "tags" {
  description = "(Optional) A map of tags to all resources that accept tags."
  type        = map(string)
  default     = {}
}

variable "create_security_group" {
  description = "(Optional) Determines if a new security group should be created. If not, an existing security group can be used as defined in existing_security_group_id. Default is `true`"
  type        = bool
  default     = true
}

variable "existing_security_group_id" {
  description = "(Optional) An existing security group to update the rules on. Default is `null`."
  type        = string
  default     = null
}

variable "security_group_name" {
  description = "(Optional) The name for the security group. If provided, overrides the security_group_name_prefix. Default is `null`."
  type        = string
  default     = null
}

variable "security_group_name_prefix" {
  description = "(Optional) The name prefix for the security group. Conflicts with security_group_name. Default is `anyscale-security-group-`."
  type        = string
  default     = "anyscale-security-group-"
}

variable "security_group_description" {
  description = "(Optional) The security group description. Default is `Anyscale Security Group`."
  type        = string
  default     = "Anyscale Security Group"
}

variable "revoke_rules_on_delete" {
  type        = bool
  description = "(Optional) Deterimines if Terraform needs to revoke all of the Security Group's attached ingress and egress rules before deleting the security group itself. Default is `false`."
  default     = false
}

variable "security_group_create_timeout" {
  type        = string
  description = "(Optional) How long to wait for the security group to be created. Default is `10m` (10 minutes). "
  default     = "10m"
}

variable "security_group_delete_timeout" {
  type        = string
  description = "(Optional) How long to wait for a deletion of a security group. Default is `15m` (15 minutes)."
  default     = "15m"
}

# Anyscale Stack Version
variable "create_anyscale_public_ingress" {
  type        = bool
  description = "(Optional) Determines if public ingress rules should be created. Default is `false`."
  default     = false
}

# ---------------------
# Security Group Rules
# ---------------------
#  Ingress Rules
variable "ingress_with_self" {
  description = "(Optional) List of ingress rules to create where 'self' is defined. Default rule is `all-all` as this security group is used for all Anyscale resources."
  type        = list(map(string))
  default = [
    {
      rule = "all-all"
    }
  ]
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
variable "ingress_with_existing_security_groups_map" {
  description = "(Optional) List of security groups and rules to allow ingress from. Default is an empty list."
  type        = list(map(string))
  default     = []
}

# Anyscale v1 Stack Related
variable "anyscale_public_ips_cidr" {
  description = "(Optional) List of Anyscale Public IPs in CIDR format. While optional, this is required for Anyscale v1 stack."
  type        = list(string)
  default = [
    "35.162.67.121/32",
    "44.226.216.241/32",
    "44.232.121.23/32",
    "44.237.42.239/32",
    "52.33.0.137/32"
  ]
}

variable "anyscale_ingress_rules_v1" {
  description = "(Optional) List of ingress rules to create. This is only used for Anyscale v1 stacks. Default is https, http, ssh."
  type        = list(string)
  default = [
    "https-443-tcp",
    "ssh-tcp"
  ]
}

# Default CIDR Range to allow access from
variable "default_ingress_cidr_range" {
  description = "(Optional) List of IPv4 cidr ranges to default to if a specific mapping isn't provided (see below example). Default is an empty list."
  type        = list(string)
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
#     rule        = "http-80-tcp"
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
variable "ingress_from_cidr_map" {
  description = "(Optional) List of ingress rules to create with cidr ranges. Default is an empty list."
  type        = list(map(string))
  default     = []
}

#  Egress Rules
variable "egress_to_self" {
  description = "(Optional) List of egress rules to create where 'self' is defined. Default is rule `all-all`."
  type        = list(map(string))
  default = [
    {
      rule = "all-all"
    }
  ]
}

variable "default_egress_cidr_range" {
  description = "(Optional) List of default IPv4 cidr ranges to use on egress rules. Default is `0.0.0.0/0`."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "egress_to_cidr_map" {
  description = "(Optional) List of egress rules to create with cidr ranges. Default is an empty list."
  type        = list(map(string))
  default     = []
}

variable "allow_all_egress" {
  description = "(Optional) Determines of egress to all on cidr range 0.0.0.0/0 is allowed. Default is `true`"
  type        = bool
  default     = true
}

# --------------------
# Pre-defined rules
#   These are reuqired
# --------------------
variable "predefined_rules" {
  # tflint-ignore: terraform_standard_module_structure
  description = "(Required) Map of predefined security group rules."
  type        = map(list(any))

  default = {
    all-all = [-1, -1, "-1", "All protocols"]
    # HTTP
    http-80-tcp = [80, 80, "tcp", "HTTP"]
    # HTTPS
    https-443-tcp = [443, 443, "tcp", "HTTPS"]
    # SSH
    ssh-tcp = [22, 22, "tcp", "SSH"]
    # NFS
    nfs-tcp = [2049, 2049, "tcp", "NFS/EFS"]
  }
}
