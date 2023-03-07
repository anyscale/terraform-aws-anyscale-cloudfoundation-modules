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

variable "anyscale_vpc_name" {
  description = "(Optional) VPC name. Will default to `vpc_<anyscale_cloud_id>`."
  type        = string
  default     = null
}

variable "tags" {
  description = "(Optional) A map of tags to add to all resources. Default is none."
  type        = map(string)
  default     = {}
}

#--------------
# VPC Resource
#--------------
variable "existing_vpc_id" {
  description = <<-EOT
    (Optional)
    An existing VPC ID. If provided, this will skip creating an Anyscale VPC.
    If no existing Subnet IDs are provided (`existing_subnet_ids`), but `existing_vpc_id` is provided, then new subnets will be created in this VPC.
    Default is `null`.
  EOT
  type        = string
  default     = null
}

variable "cidr_block" {
  description = "(Optional) The IPv4 CIDR block for the VPC. CIDR can be explicitly set or it can be derived from IPAM using `ipv4_netmask_length` & `ipv4_ipam_pool_id`. Default is `10.0.0.0/16`"
  type        = string
  default     = "10.0.0.0/16"
}
variable "secondary_cidr_blocks" {
  description = "(Optional) List of secondary CIDR blocks to associate with the VPC to extend the IP Address pool. Default is an empty list."
  type        = list(string)
  default     = []
}

variable "enable_vpc_dns_hostnames" {
  description = "(Optional) Determines if DNS hostnames are enabled on the VPC. Default is `true`"
  type        = bool
  default     = true
}

variable "enable_vpc_dns_support" {
  description = "(Optional) Determines if DNS support is enabled on the VPC. Default is `true`."
  type        = bool
  default     = true
}

variable "vpc_instance_tenancy" {
  description = "(Optional) A tenancy option for instances launched into the VPC. Default is `default`"
  type        = string
  default     = "default"
  validation {
    condition     = contains(["default", "dedicated"], var.vpc_instance_tenancy)
    error_message = "The vpc_instance_tenancy value must either be `default` or `dedicated`."
  }
}

# IPAM Pool for CIDR Range
variable "use_ipam_pool" {
  description = "(Optional) Determines whether IPAM pool is used for CIDR allocation. Default is `false`"
  type        = bool
  default     = false
}
variable "ipv4_ipam_pool_id" {
  description = "(Optional) The ID of an IPv4 IPAM pool you want to use for allocating this VPC's CIDR. Default is `null`."
  type        = string
  default     = null
}
variable "ipv4_netmask_length" {
  description = "(Optional) The netmask length of the IPv4 CIDR you want to allocate to this VPC. Requires specifying a ipv4_ipam_pool_id. Default is `null`."
  type        = number
  default     = null
}


# --------
# Subnets
# --------
# Public Subnets
# ex:
# public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
variable "public_subnets" {
  description = <<-EOT
    (Optional)
    A list of public subnets inside the VPC.
    If you are creating subnets in an existing VPC (using existing_vpc_id),
    please make sure that the number of subnets in the list is less than or
    equal to the number of AZ's in the region.

    Default is an empty list.
  EOT
  type        = list(string)
  default     = []
}
variable "public_subnet_suffix" {
  description = "(Optional) Suffix to append to public subnets name. Default is `public`"
  type        = string
  default     = "public"
}
variable "public_subnet_names" {
  description = "(Optional) Explicit values to use in the Name tag on public subnets. If empty, Name tags are generated. Default is an empty list."
  type        = list(string)
  default     = []
}
variable "map_public_ip_on_launch" {
  description = "(Optional) Determines if public subnets should auto-assign public IPs on launch. Defualt is `true`."
  type        = bool
  default     = true
}
variable "existing_public_route_table_ids" {
  description = <<-EOT
    (Optional)
    A list of existing Route Tables for public subnets.
    If provided and if `gateway_vpc_endpoints` is also provided,
    this will create a route to the gateway endpoint.

    Default is an empty list.
  EOT
  type        = list(string)
  default     = []
}

# Private Subnets
# ex:
# private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
variable "private_subnets" {
  description = <<-EOT
    (Optional)
    A list of private subnets inside a VPC.
    If you are creating subnets in an existing VPC (using existing_vpc_id),
    please make sure that the number of subnets in the list is less than or
    equal to the number of AZ's in the region.

    Default is an empty list.
  EOT
  type        = list(string)
  default     = []
}
variable "private_subnet_suffix" {
  description = "(Optional) Suffix to append to private subnets name. Default is `private`."
  type        = string
  default     = "private"
}
variable "private_subnet_names" {
  description = "(Optional) Explicit values to use in the Name tag on private subnets. If empty, Name tags are generated. Default is an empty list."
  type        = list(string)
  default     = []
}
variable "existing_private_route_table_ids" {
  description = <<-EOT
    (Optional)
    A list of existing Route Tables for private subnets.
    If you are creating new private subnets in an existing VPC, this will provide the mapping from
    subnet to route table. If only 1 route table is provided, all new subnets will be associated with that one.
    If more than one, please make sure that you provide the same number of route tables as subnets.

    Default is an empty list.
  EOT
  type        = list(string)
  default     = []
}

variable "existing_private_subnet_ids" {
  description = <<-EOT
    (Optional)
    A list of existing private subnets.
    If this variable and var.existing_vpc_id are both provided, the aws-anyscale-vpc sub-module will not create a VPC or Subnets.
    It will only create VPC Endpoints if the gateway_vpc_endpoints variable is defined.

    Default is an empty list.
  EOT
  type        = list(string)
  default     = []
}

# Availability Zones
variable "availability_zones" {
  description = "(Optional) A list of availability zones names in the region. Default is an empty list, and dynamically chosen."
  type        = list(string)
  default     = []
}
variable "availability_zone_ids" {
  description = "(Optional) A list of availability zones ids in the region. Default is an empty list, and dynamically chosen."
  type        = list(string)
  default     = []
}
variable "max_az_count" {
  description = "(Optional) The max count of availability zones to use/identify. Default is `0`."
  type        = number
  default     = 0
}

# -------------------
# NAT Gateways (NGW)
# -------------------
variable "create_ngw" {
  description = "(Optional) Determines if a NAT Gateway should be created for private networks. Depends on Public/Private Subnets being created. Default is `true`."
  type        = bool
  default     = true
}

variable "max_nat_gateway_count" {
  description = "Upper limit on number of NAT Gateways to create. Set to `1` to only create one NAT Gateway. Default is `999` but will default to number of availability zones as the max."
  type        = number
  default     = 999
}

variable "nat_gateway_destination_cidr_block" {
  description = "(Optional) Defines a custom destination route for NAT Gateway(s). Default is `0.0.0.0/0`."
  type        = string
  default     = "0.0.0.0/0"
}

# ------------------------
# Internet Gateways (IGW)
# ------------------------
variable "create_igw" {
  description = "(Optional) Determines if an Internet Gateway is created for public subnets. Requires public_subnets list to be provided. Default is `true`."
  type        = bool
  default     = true
}

# ----------
# Flow logs
# ----------
variable "enable_vpc_flow_logs" {
  description = "(Optional) Determines if VPC Flow Logs should be enabled. Default is `false`."
  type        = bool
  default     = false
}

variable "create_flow_log_cloudwatch_log_group" {
  description = "(Optional) Determines whether to create CloudWatch log group for VPC Flow Logs. Default is `false`."
  type        = bool
  default     = false
}

variable "flow_log_cloudwatch_log_group_name_prefix" {
  description = "(Optional) Specifies the name prefix of CloudWatch Log Group for VPC flow logs. Default is `/aws/vpc-flow-log/`"
  type        = string
  default     = "/aws/vpc-flow-log/"
}

variable "flow_log_cloudwatch_log_group_name_suffix" {
  description = "(Optional) Specifies the name suffix of CloudWatch Log Group for VPC flow logs. If none is provided, will append the VPC Name. Default is `null`"
  type        = string
  default     = null
}

variable "flow_log_cloudwatch_log_group_retention_in_days" {
  description = "(Optional) Specifies the number of days you want to retain log events in the specified log group for VPC flow logs. Default is `null` which is unlimited."
  type        = number
  default     = null
}

variable "flow_log_cloudwatch_log_group_kms_key_id" {
  description = "(Optional) The ARN of the KMS Key to use when encrypting log data for VPC flow logs. Default is `null`."
  type        = string
  default     = null
}

variable "create_flow_log_cloudwatch_iam_role" {
  description = "(Optional) Determines whether to create IAM role for VPC Flow Logs. Default is `false`."
  type        = bool
  default     = false
}

variable "vpc_flow_log_permissions_boundary" {
  description = "(Optional) ARN of a Permissions Boundary for the VPC Flow Log IAM Role. Default is `null`"
  type        = string
  default     = null
}

# "s3" = {
#   name = "s3"
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "s3:*",
#         ]
#         Effect    = "Allow"
#         Principal = "*"
#         Resource  = "*"
#       },
#     ]
#   })
# }
# "dynamodb" = {
#   name            = "dynamodb"
#   policy          = null
# }
# VPC Endpoints - Only supporting Gateway endpoints for now.
variable "gateway_vpc_endpoints" {
  type = map(object({
    name   = string
    policy = string
  }))
  description = <<-EOD
    A map of Gateway VPC Endpoints to provision into the VPC. This is a map of objects with the following attributes:
    - `name`: Short service name (either "s3" or "dynamodb")
    - `policy` = A policy (as JSON string) to attach to the endpoint that controls access to the service. May be `null` for full access.
    Set to an empty map `{}` to skip creating VPC Endpoints.
    Default is S3 with an empty (full access) policy.
    EOD
  default = {
    "s3" = {
      name   = "s3"
      policy = null
    }
  }
}
