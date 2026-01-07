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

# Machine Pool Security Group
variable "machine_pool_security_group_name" {
  description = <<-EOT
    (Optional) Name for the machine pool security group.

    ex:
    ```
    machine_pool_security_group_name = "anyscale-machine-pool-sg"
    ```
  EOT
  type        = string
  default     = null
}

variable "machine_pool_security_group_name_prefix" {
  description = <<-EOT
    (Optional) Name prefix for the machine pool security group.

    ex:
    ```
    machine_pool_security_group_name_prefix = "anyscale-machine-pool-sg-"
    ```
  EOT
  type        = string
  default     = "anyscale-machine-pool-sg-"
}

variable "machine_pool_security_group_description" {
  description = <<-EOT
    (Optional) Description for the machine pool security group.

    ex:
    ```
    machine_pool_security_group_description = "Anyscale Machine Pool Security Group"
    ```
  EOT
  type        = string
  default     = "Anyscale Machine Pool Security Group"
}

variable "machine_pool_cidr_ranges" {
  description = <<-EOT
    (Optional) List of CIDR ranges to allow ingress from machine pools.

    **IMPORTANT**: Due to AWS security group limits (60 rules max) and the number of port ranges (22),
    this variable is limited to a maximum of 2 CIDR ranges. With 3 or more CIDR ranges, you would exceed
    the AWS security group rule limit (22 port ranges × 3 CIDR ranges = 66 rules > 60 limit).

    ex:
    ```
    machine_pool_cidr_ranges = ["10.100.10.0/24", "10.100.11.0/24"]
    ```
  EOT
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.machine_pool_cidr_ranges) <= 2
    error_message = "machine_pool_cidr_ranges cannot exceed 2 CIDR ranges due to AWS security group rule limits (60 rules max). Current configuration would create ${length(var.machine_pool_cidr_ranges) * 22} rules, exceeding the limit."
  }
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
#   These are required
# --------------------
variable "machine_pool_port_ranges" {
  description = "(Optional) List of port ranges for machine pools. Each range will create a separate security group rule."
  type = list(object({
    from_port   = number
    to_port     = number
    description = string
  }))
  default = [
    {
      from_port   = 80
      to_port     = 80
      description = "HTTP"
    },
    {
      from_port   = 443
      to_port     = 443
      description = "HTTPS"
    },
    {
      from_port   = 1010
      to_port     = 1012
      description = "Anyscale Services (1010-1012)"
    },
    {
      from_port   = 2222
      to_port     = 2222
      description = "SSH Alternative"
    },
    {
      from_port   = 5555
      to_port     = 5555
      description = "Anyscale Service"
    },
    {
      from_port   = 5903
      to_port     = 5903
      description = "VNC"
    },
    {
      from_port   = 6379
      to_port     = 6379
      description = "Redis"
    },
    {
      from_port   = 6822
      to_port     = 6824
      description = "Anyscale Services (6822-6824)"
    },
    {
      from_port   = 6826
      to_port     = 6826
      description = "Anyscale Service"
    },
    {
      from_port   = 7878
      to_port     = 7878
      description = "Anyscale Service"
    },
    {
      from_port   = 8000
      to_port     = 8000
      description = "Health Checks"
    },
    {
      from_port   = 8076
      to_port     = 8076
      description = "Anyscale Service"
    },
    {
      from_port   = 8085
      to_port     = 8085
      description = "Anyscale Service"
    },
    {
      from_port   = 8201
      to_port     = 8201
      description = "Anyscale Service"
    },
    {
      from_port   = 8265
      to_port     = 8266
      description = "Anyscale Services (8265-8266)"
    },
    {
      from_port   = 8686
      to_port     = 8687
      description = "Anyscale Services (8686-8687)"
    },
    {
      from_port   = 8912
      to_port     = 8912
      description = "Anyscale Service"
    },
    {
      from_port   = 8999
      to_port     = 8999
      description = "Anyscale Service"
    },
    {
      from_port   = 9090
      to_port     = 9090
      description = "Prometheus"
    },
    {
      from_port   = 9092
      to_port     = 9092
      description = "Kafka"
    },
    {
      from_port   = 9100
      to_port     = 9100
      description = "Node Exporter"
    },
    {
      from_port   = 9478
      to_port     = 9482
      description = "Anyscale Services (9478-9482)"
    }
  ]
}

variable "predefined_rules" {
  # tflint-ignore: terraform_standard_module_structure
  description = "(Required) Map of predefined security group rules."
  type = map(object({
    from_port   = number
    to_port     = number
    protocol    = string
    description = string
  }))

  default = {
    all-all = {
      from_port   = -1
      to_port     = -1
      protocol    = "-1"
      description = "All protocols"
    }
    # HTTP
    http-80-tcp = {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP"
    }
    # HTTPS
    https-443-tcp = {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS"
    }
    # SSH
    ssh-tcp = {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH"
    }
    # NFS
    nfs-tcp = {
      from_port   = 2049
      to_port     = 2049
      protocol    = "tcp"
      description = "NFS/EFS"
    }
    # Health Checks
    health-checks = {
      from_port   = 8000
      to_port     = 8000
      protocol    = "tcp"
      description = "Health Checks"
    }
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
