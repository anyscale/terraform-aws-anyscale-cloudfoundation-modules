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
  description = <<-EOT
    (Optional) Whether to create the resources inside this module.

    ex:
    ```
    module_enabled = true
    ```
  EOT
  type        = bool
  default     = true
}

variable "tags" {
  description = <<-EOT
    (Optional) A map of tags to all resources that accept tags.

    ex:
    ```
    tags = {
      test        = true
      environment = "test"
    }
    ```
  EOT
  type        = map(string)
  default     = {}
}

variable "create_security_group" {
  description = <<-EOT
    (Optional) Determines if a new security group should be created.

    If not, an existing security group can be used as defined in `existing_security_group_id`.

    ex:
    ```
    create_security_group = true
    ```
  EOT
  type        = bool
  default     = true
}

variable "existing_security_group_id" {
  description = <<-EOT
    (Optional) An existing security group to update the rules on.

    If `create_security_group` is set to false, this must be provided.

    ex:
    ```
    existing_security_group_id = "sg-0123456789001ab8e"
    ```
  EOT
  type        = string
  default     = null
}

variable "security_group_name" {
  description = <<-EOT
    (Optional) The name for the security group.

    If left `null`, will default to `security_group_name_prefix`.
    If provided, overrides the `security_group_name_prefix` variable.

    ex:
    ```
    security_group_name = "anyscale-security-group"
    ```
  EOT
  type        = string
  default     = null
}

variable "security_group_name_prefix" {
  description = <<-EOT
    (Optional) The name prefix for the security group.

    If `security_group_name` is provided, it will override this variable.

    ex:
    ```
    security_group_name_prefix = "anyscale-security-group-"
    ```
  EOT
  type        = string
  default     = "anyscale-security-group-"
}

variable "security_group_description" {
  description = <<-EOT
    (Optional) The security group description.

    ex:
    ```
    security_group_description = "Anyscale Security Group"
    ```
  EOT
  type        = string
  default     = "Anyscale Security Group"
}

variable "revoke_rules_on_delete" {
  type        = bool
  description = <<-EOT
    (Optional) Deterimines if Terraform needs to revoke all of the Security Group's attached ingress and egress rules before deleting the security group itself.

    ex:
    ```
    revoke_rules_on_delete = true
    ```
  EOT
  default     = false
}


variable "create_anyscale_public_ingress" {
  type        = bool
  description = <<-EOT
    (Optional) Determines if public ingress rules should be created.

    ex:
    ```
    create_anyscale_public_ingress = true
    ```
  EOT
  default     = false
}

# variable "create_eks_cluster_security_group" {
#   type        = bool
#   description = <<-EOT
#     (Optional) Determines if Kubernetes cluster security group rules should be created.

#     ex:
#     ```
#     create_eks_cluster_security_group = true
#     ```
#   EOT
#   default     = false
# }

# variable "eks_cluster_security_group_name" {
#   description = <<-EOT
#     (Optional) The name for the EKS cluster security group.

#     If left `null`, will default to `eks_cluster_security_group_name_prefix`.
#     If provided, overrides the `eks_cluster_security_group_name_prefix` variable.

#     ex:
#     ```
#     eks_cluster_security_group_name = "anyscale-k8s-cluster-security-group"
#     ```
#   EOT
#   type        = string
#   default     = null
# }

# variable "eks_cluster_security_group_name_prefix" {
#   description = <<-EOT
#     (Optional) The name prefix for the EKS cluster security group.

#     If `eks_cluster_security_group_name` is provided, it will override this variable.
#     Default is `null` but is set to `anyscale-k8s-cluster-security-group-` in a local variable.

#     ex:
#     ```
#     eks_cluster_security_group_name_prefix = "anyscale-k8s-cluster-security-group-"
#     ```
#   EOT
#   type        = string
#   default     = null
# }

# variable "eks_cluster_security_gorup_description" {
#   description = <<-EOT
#     (Optional) The EKS cluster security group description.

#     ex:
#     ```
#     eks_cluster_security_group_description = "Anyscale EKS Cluster Security Group"
#     ```
#   EOT
#   type        = string
#   default     = "Anyscale EKS Cluster Security Group"
# }

# ---------------------
# Security Group Rules
# ---------------------
#  Ingress Rules
variable "ingress_with_self" {
  description = <<-EOT
    (Optional) List of ingress rules to create where 'self' is defined.

    Default rule is `all-all` as this security group is used for all Anyscale resources.

    ex:
    ```
    ingress_with_self = [
      {
        rule = "all-all"
      }
    ]
    ```
  EOT
  type        = list(map(string))
  default = [
    {
      rule = "all-all"
    }
  ]
}

variable "ingress_with_existing_security_groups_map" {
  description = <<-EOT
    (Optional) List of security groups and rules to allow ingress from.

    ex:
    ```
    ingress_with_existing_security_groups_map = [
      {
        rule              = "https-443-tcp"
        security_group_id = "sg-0123456789001ab8e"
      },
      {
        rule              = "ssh-tcp"
        security_group_id = "sg-0123456789001ab8e"
      }
    ]
    ```
  EOT
  type        = list(map(string))
  default     = []
}

# Anyscale v1 Stack Related
variable "anyscale_public_ips_cidr" {
  description = <<-EOT
    (Deprecated) List of Anyscale Public IPs in CIDR format.

    While optional, this is required for Anyscale v1 stack.
  EOT
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
  description = <<-EOT
    (Deprecated) List of ingress rules to create. This is only used for Anyscale v1 stacks.
  EOT
  type        = list(string)
  default = [
    "https-443-tcp",
    "ssh-tcp"
  ]
}

# Default CIDR Range to allow access from
variable "default_ingress_cidr_range" {
  description = <<-EOT
    (Optional) List of IPv4 cidr ranges to default to if a specific mapping isn't provided.

    ex:
    ```
    default_ingress_cidr_range = ["10.100.10.10/32"]
    ```
  EOT

  type    = list(string)
  default = []
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
  description = <<-EOT
    (Optional) List of ingress rules to create with cidr ranges.

    ex:
    ```
    ingress_from_cidr_map = [
      {
        rule        = "https-443-tcp"
        cidr_blocks = "10.100.10.10/32"
      },
      { rule = "nfs-tcp" },
      {
        rule        = "http-80-tcp"
        cidr_blocks = "10.100.10.10/32"
      },
      {
        from_port   = 10
        to_port     = 20
        protocol    = 6
        description = "Service name is TEST"
        cidr_blocks = "10.100.10.10/32"
      }
    ]
    ```
  EOT
  type        = list(map(string))
  default     = []
}

#  Egress Rules
variable "egress_to_self" {
  description = <<-EOT
    (Optional) List of egress rules to create where 'self' is defined.

    Changing this may have unintended consequences.

    ex:
    ```
    egress_to_self = [
      {
        rule = "all-all"
      }
    ]
    ```
  EOT
  type        = list(map(string))
  default = [
    {
      rule = "all-all"
    }
  ]
}

variable "default_egress_cidr_range" {
  description = <<-EOT
    (Optional) List of default IPv4 cidr ranges to use on egress rules.

    ex:
    ```
    default_egress_cidr_range = ["0.0.0.0/0"]
    ```
  EOT
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "egress_to_cidr_map" {
  description = <<-EOT
    (Optional) List of egress rules to create with cidr ranges.

    ex:
    ```
    egress_to_cidr_map = [
      {
        rule        = "https-443-tcp"
        cidr_blocks = "0.0.0.0/0"
      },
      {
        rule        = "http-80-tcp"
        cidr_blocks = "0.0.0.0/0"
      }
    ]
    ```
  EOT
  type        = list(map(string))
  default     = []
}

variable "allow_all_egress" {
  description = <<-EOT
    (Optional) Determines of egress to all on cidr range 0.0.0.0/0 is allowed.

    Changing this may have unintended consequences.

    ex:
    ```
    allow_all_egress = true
    ```
  EOT
  type        = bool
  default     = true
}

# --------------------
# Pre-defined rules
#   These are reuqired
# --------------------
variable "predefined_rules" {
  # tflint-ignore: terraform_standard_module_structure
  description = <<-EOT
    (Required) Map of predefined security group rules.
  EOT
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

# Terraform Timeout Settings
variable "security_group_create_timeout" {
  type        = string
  description = <<-EOT
    (Optional) How long to wait for the security group to be created in minutes.

    ex:
    ```
    security_group_create_timeout = "10m"
    ```
  EOT
  default     = "10m"
}

variable "security_group_delete_timeout" {
  type        = string
  description = <<-EOT
    (Optional) How long to wait for a deletion of a security group in minutes.

    ex:
    ```
    security_group_delete_timeout = "15m"
    ```
  EOT
  default     = "15m"
}
