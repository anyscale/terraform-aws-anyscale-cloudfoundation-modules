# ------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables must be set when using this module.
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These variables have defaults, but may be overridden.
# ------------------------------------------------------------------------------
variable "anyscale_cloud_id" {
  description = <<-EOT
    (Optional) Anyscale Cloud ID.

    ex:
    ```
    anyscale_cloud_id = "cld_1234567890abcdef0"
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
    (Optional) Determines if this module should create resources.

    If set to true, `eks_role_arn`, and `anyscale_subnet_ids` must be provided.
    ex:
    ```
    module_enabled = true
    ```
  EOT
  type        = bool
  default     = false
}

variable "tags" {
  description = <<-EOT
    (Optional) A map of tags to add to all resources.

    If cloud_id is provided, it will be added to the tags.

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

# ------------------
# EKS Configuration
# ------------------
variable "eks_role_arn" {
  description = <<-EOT
    (Optional) The ARN of the IAM role to use for the EKS cluster.

    Required if `module_enabled` is true.

    ex:
    ```
    anyscale_eks_role_arn = "arn:aws:iam::123456789012:role/eks-service-role"
    ```
  EOT
  type        = string
  default     = null
}

variable "anyscale_eks_name" {
  description = <<-EOT
    (Optional) Anyscale EKS Name.

    If left `null`, will default to `anyscale-eks` in a local variable.

    ex:
    ```
    anyscale_eks_name = "anyscale-eks"
    ```
  EOT
  type        = string
  default     = null
}

variable "include_version_in_name" {
  description = <<-EOT
    (Optional) Determines if the Kubernetes version should be included in the EKS cluster name.

    If `anyscale_eks_name` is provided, it will override this variable.

    ex:
    ```
    include_version_in_name = true
    ```
  EOT
  type        = bool
  default     = true
}

variable "kubernetes_version" {
  description = <<-EOT
    (Optional) The Kubernetes version to use for the EKS cluster.

    Must be on EKS v1.28 or greater.
    Downgrades are not supported.

    ex:
    ```
    kubernetes_version = "1.28"
    ```
  EOT
  type        = string
  default     = "1.30"

  validation {
    condition     = can(regex("^(1\\.(2[89]|[3-9][0-9]))$", var.kubernetes_version))
    error_message = "The Kubernetes version must be 1.28 or greater."
  }
}

variable "enabled_cluster_log_types" {
  description = <<-EOT
    (Optional) A list of the desired control plane logs to enable.

    For more information, see Amazon EKS Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)

    ex:
    ```
    enabled_cluster_log_types = ["api", "audit", "authenticator"]
    ```
  EOT
  type        = list(string)
  default     = []
}

# ------------------
# EKS VPC Configuration
# ------------------
variable "anyscale_subnet_ids" {
  description = <<-EOT
    (Optional) A list of subnet IDs to use for the EKS cluster.

    Required if `module_enabled` is true.

    ex:
    ```
    anyscale_subnet_ids = ["subnet-1234567890abcdef0", "subnet-1234567890abcdef1"]
    ```
  EOT
  type        = list(string)
  default     = []
}

variable "anyscale_subnet_count" {
  description = <<-EOT
    (Optional) The mount targets subnet count.

    This is included as the number of subnets is not always known at the creation time.

    ex:
    ```
    anyscale_subnet_count = 2
    ```
  EOT
  type        = number
  default     = 0
}


variable "eks_cluster_securitygroup_id" {
  description = <<-EOT
    (Optional) The ID of the security group to use for the EKS cluster.

    Required if `create_eks_cluster_securitygroup` is false.

    ex:
    ```
    eks_cluster_securitygroup_id = "sg-1234567890abcdef0"
    ```
  EOT
  type        = string
  default     = null
}

variable "anyscale_security_group_id" {
  description = <<-EOT
    (Optional) Anyscale Security Group ID.

    Required if `module_enabled` is true.

    ex:
    ```
    anyscale_security_group_id = "sg-1234567890abcdef0"
    ```
  EOT
  type        = string
  default     = null
}

variable "additional_security_group_ids" {
  description = <<-EOT
    (Optional) A list of additional security group IDs to use for the EKS cluster.

    ex:
    ```
    additional_security_group_ids = ["sg-1234567890abcdef1", "sg-1234567890abcdef2"]
    ```
  EOT
  type        = list(string)
  default     = []
}

variable "eks_endpoint_private_access" {
  description = <<-EOT
    (Optional) Determines whether or not the Amazon EKS private API server endpoint is enabled.

    ex:
    ```
    eks_endpoint_private_access = true
    ```
  EOT
  type        = bool
  default     = false
}

variable "eks_endpoint_public_access" {
  description = <<-EOT
    (Optional) Indicates whether or not the Amazon EKS public API server endpoint is enabled

    ex:
    ```
    eks_endpoint_public_access = true
    ```
  EOT
  type        = bool
  default     = true
}

variable "eks_endpoint_public_access_cidrs" {
  description = <<-EOT
    (Optional) List of CIDR blocks that are allowed to access the Amazon EKS public API server endpoint.

    ex:
    ```
    eks_endpoint_public_access_cidrs = ["12.1.30.32/32", "13.10.0.0/16"]
    ```
  EOT
  type        = list(string)
  default     = ["0.0.0.0/0"]
}


variable "eks_cluster_encryption_config_kms_key_arn" {
  description = <<-EOT
    (Optional) KMS Key ID to use for cluster encryption config

    ex:
    ```
    eks_cluster_encryption_config_kms_key_arn = "arn:aws:kms:us-west-2:123456789012:key/12345678-1234-1234-1234-123456789012"
    ```
  EOT
  type        = string
  default     = null
}

variable "eks_cluster_encryption_config_resources" {
  description = <<-EOT
    (Optional) Cluster Encryption Config Resources to encrypt.

    ex:
    ```
    eks_cluster_encryption_config_resources = ["secrets"]
    ```
  EOT
  type        = list(any)
  default     = ["secrets"]
}

# ------------------
# EKS Addons
# ------------------
variable "eks_addons" {
  type = list(object({
    addon_name                  = string
    addon_version               = optional(string, null)
    configuration_values        = optional(string, null)
    resolve_conflicts_on_create = optional(string, null)
    resolve_conflicts_on_update = optional(string, null)
    service_account_role_arn    = optional(string, null)
    create_timeout              = optional(string, null)
    update_timeout              = optional(string, null)
    delete_timeout              = optional(string, null)
  }))
  description = <<-EOT
    (Optional) Manages [`aws_eks_addon`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) resources.

    ex:
    ```
    eks_addons = [
      {
        addon_name           = "vpc-cni"
        addon_version        = "1.8.0"
        configuration_values = null
        resolve_conflicts_on_create = null
        resolve_conflicts_on_update = null
        service_account_role_arn    = null
        create_timeout              = null
        update_timeout              = null
        delete_timeout              = null
      }
    ]
    ```
    EOT
  default     = []
}

variable "eks_addons_depends_on" {
  type        = any
  description = <<-EOT
    (Optional) If provided, all addons will depend on this object, and therefore not be installed until this object is finalized.

    This is useful if you want to ensure that addons are not applied before some other condition is met, e.g. node groups are created.

    ex:
    ```
    addons_depends_on = [aws_eks_node_group.management]
    ```
    EOT
  default     = null
}
