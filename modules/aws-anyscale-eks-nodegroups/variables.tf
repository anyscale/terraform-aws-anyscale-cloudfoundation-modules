# ------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables must be set when using this module.
# ------------------------------------------------------------------------------
variable "eks_cluster_name" {
  description = <<-EOT
    (Required) The name of the EKS cluster.

    ex:
    ```
    cluster_name = "anyscale-cluster"
    ```
  EOT
  type        = string
}

variable "eks_node_role_arn" {
  description = <<-EOT
    (Required) The ARN of the IAM role to use for the EKS nodes.

    ex:
    ```
    eks_node_role_arn = "arn:aws:iam::123456789012:role/eks-node-role"
    ```
  EOT
  type        = string
}

variable "subnet_ids" {
  description = <<-EOT
    (Required) A list of subnet IDs to use for the EKS nodes.

    ex:
    ```
    subnet_ids = ["subnet-1234567890abcdef0", "subnet-1234567890abcdef1"]
    ```
  EOT
  type        = list(string)
}

# ------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These variables have defaults, but may be overridden.
# ------------------------------------------------------------------------------
# variable "anyscale_cloud_id" {
#   description = <<-EOT
#     (Optional) Anyscale Cloud ID.

#     ex:
#     ```
#     anyscale_cloud_id = "cld_1234567890abcdef0"
#     ```
#   EOT
#   type        = string
#   default     = null
#   validation {
#     condition = (
#       var.anyscale_cloud_id == null ? true : (
#         length(var.anyscale_cloud_id) > 4 &&
#         substr(var.anyscale_cloud_id, 0, 4) == "cld_"
#       )
#     )
#     error_message = "The anyscale_cloud_id value must start with \"cld_\"."
#   }
# }

variable "module_enabled" {
  description = <<-EOT
    (Optional) Determines if this module should create resources.

    If set to true, `eks_role_arn`, `anyscale_subnet_ids`, and `anyscale_security_group_id` must be provided.
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

variable "force_update_version" {
  description = <<-EOT
    (Optional) Determines if, when updating the Kubernetes version, pods are foreably removed.

    If set to true, if PodDisruptionBudget or taint/toleration issues would otherwise prevent them from being removed (and cause the update to fail) it will be removed.

    ex:
    ```
    force_update_version = true
    ```
  EOT
  type        = bool
  default     = false
}

variable "node_group_timeouts" {
  description = <<-EOT
    (Optional) Create, update, and delete timeout configurations for the node group

    ex:
    ```
    node_group_timeouts = {
      create = "30m"
      update = "30m"
      delete = "30m"
    }
    ```
  EOT
  type        = map(string)
  default     = {}
}

# ------------------
# EKS Management Node Group Configuration
# ------------------
variable "create_eks_management_node_group" {
  description = <<-EOT
    (Optional) Determines if this module should create a EKS Management Node Group.

    The EKS Management Node Group will be use for EKS Management pods.

    If set to true, `eks_role_arn`, `anyscale_subnet_ids`, and `anyscale_security_group_id` must be provided.
    ex:
    ```
    create_eks_management_node_group = true
    ```
  EOT
  type        = bool
  default     = true
}

variable "eks_management_node_group_name" {
  description = <<-EOT
    (Optional) Anyscale EKS Management Node Group Name.

    ex:
    ```
    eks_management_node_group_name = "eks-mng"
    ```
  EOT
  type        = string
  default     = "eks-mng"
}

variable "eks_management_instance_types" {
  description = <<-EOT
    (Optional) A list of instance types to use for the EKS Management Node Group.

    ex:
    ```
    eks_management_instance_types = ["m5.large"]
    ```
  EOT
  type        = list(string)
  default     = ["t3.medium"]
}

variable "eks_management_capacity_type" {
  type        = string
  description = <<-EOT
    (Optional) Type of capacity associated with the EKS Node Group.

    ex:
    ```
    capacity_type = "ON_DEMAND"
    ```

    EOT
  default     = null
  validation {
    condition = (
      var.eks_management_capacity_type == null ? true : (
        var.eks_management_capacity_type == "ON_DEMAND" || var.eks_management_capacity_type == "SPOT"
      )
    )
    error_message = "`eks_management_capacity_type` only allows `ON_DEMAND`, `SPOT`, or `null`"
  }
}

variable "eks_manamgenet_desired_size" {
  description = <<-EOT
    (Optional) The desired number of nodes for the EKS Management Node Group.

    ex:
    ```
    eks_manamgenet_desired_size = 2
    ```
  EOT
  type        = number
  default     = 2
}

variable "eks_management_max_size" {
  description = <<-EOT
    (Optional) The maximum number of nodes for the EKS Management Node Group.

    ex:
    ```
    eks_management_max_size = 4
    ```
  EOT
  type        = number
  default     = 4
}

variable "eks_management_min_size" {
  description = <<-EOT
    (Optional) The minimum number of nodes for the EKS Management Node Group.

    ex:
    ```
    eks_management_min_size = 1
    ```
  EOT
  type        = number
  default     = 1
}

variable "eks_management_labels" {
  description = <<-EOT
    (Optional) A map of labels to add to the EKS Management Node Group.

    ex:
    ```
    eks_management_labels = {
      "node-type" = "management"
    }
    ```
  EOT
  type        = map(string)
  default = {
    "node-type" = "management"
  }
}

variable "eks_management_tags" {
  description = <<-EOT
    (Optional) A map of tags to add to the EKS Management Node Group.

    ex:
    ```
    eks_management_tags = {
      "test"        = true
      "environment" = "test"
    }
    ```
  EOT
  type        = map(string)
  default     = {}
}

variable "eks_management_taints" {
  description = <<-EOT
    (Optional) A list of taints to add to the EKS Management Node Group.

    Valid effects are: `NO_SCHEDULE`, `PREFER_NO_SCHEDULE`, and `NO_EXECUTE`.

    ex:
    ```
    eks_management_taints = [
      {
        key    = "node-type"
        value  = "management"
        effect = "NO_SCHEDULE"
      }
    ]
    ```
  EOT
  type        = list(map(string))
  default     = []

  validation {
    condition     = can(regex("^(NO_SCHEDULE|PREFER_NO_SCHEDULE|NO_EXECUTE)$", var.eks_management_taints[0].effect)) || length(var.eks_management_taints) == 0
    error_message = "The taint effect must be `NO_SCHEDULE`, `PREFER_NO_SCHEDULE`, or `NO_EXECUTE`."
  }
}

variable "eks_management_update_config" {
  description = <<-EOT
    (Optional) Configuration block of settings for max unavailable resources during node group updates.

    ex:
    ```
    eks_management_update_config = {
      max_unavailable_percentage = 33,
      max_unavailable            = 5
    }
    ```
  EOT
  type        = map(string)
  default = {
    max_unavailable_percentage = 33
  }
}

# ------------------
# EKS Anyscale Node Group Configuration
# ------------------
# variable "anyscale_node_group_name" {
#   description = <<-EOT
#     (Optional) Anyscale EKS Node Group Name Name.

#     If not provided, the name will be generated based on the cloud_id.

#     ex:
#     ```
#     anyscale_eks_name = "anyscale-eks"
#     ```
#   EOT
#   type        = string
#   default     = null
# }
