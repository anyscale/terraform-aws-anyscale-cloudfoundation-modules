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

    If set to true, `eks_cluster_name`, `eks_node_role_arn`, and `anyscale_subnet_ids` must be provided.
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
  type = list(object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
  }))
  default = [
    {
      create = "20m"
      update = "20m"
      delete = "20m"
    }
  ]
}

# ------------------
# EKS Management Node Group Configuration
# ------------------
variable "create_eks_management_node_group" {
  description = <<-EOT
    (Optional) Determines if this module should create a EKS Management Node Group.

    The EKS Management Node Group will be use for EKS Management pods.

    ex:
    ```
    create_eks_management_node_group = true
    ```
  EOT
  type        = bool
  default     = true
}

variable "eks_management_node_group_config" {
  description = <<-EOT
    (Optional) Configuration for the EKS Management Node Group.

    ex:
    ```
    eks_management_node_group_config = {
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      desired_size   = 2
      max_size       = 4
      min_size       = 1
      labels         = {
        "node-type" = "management"
      }
      tags           = {
        "test"        = true
        "environment" = "test"
      }
      ami_type      = "AL2_x86_64"
      taints = [
        {
          key    = "node-type"
          value  = "management"
          effect = "NO_SCHEDULE"
        }
      ]
      update_config = {
        max_unavailable_percentage = 33
      }
    }
    ```
  EOT
  type = object({
    name           = string
    instance_types = list(string)
    capacity_type  = string
    labels         = optional(map(string))
    tags           = optional(map(string))
    ami_type       = optional(string)
    scaling_config = object({
      desired_size = number
      max_size     = number
      min_size     = number
    })
    update_config = optional(object({
      max_unavailable_percentage = optional(number)
      max_unavailable            = optional(number)
    }))
    taints = optional(list(
      object({
        key    = string
        value  = string
        effect = string
      })
    ))
  })
  default = {
    name           = "eks-mng"
    instance_types = ["t3.medium"]
    capacity_type  = "ON_DEMAND"
    scaling_config = {
      desired_size = 2
      max_size     = 4
      min_size     = 1
    }
    labels = {
      "node-type" = "management"
    }
    tags     = {}
    ami_type = "AL2_x86_64"
    taints   = []
    update_config = {
      max_unavailable_percentage = 33
    }
  }
}

# ------------------------------------------------------------------------------
# Anyscale EKS Node Group Configurations
# ------------------------------------------------------------------------------
variable "create_anyscale_node_groups" {
  description = <<-EOT
    (Optional) Determines if this module should create Anyscale EKS Node Groups.

    ex:
    ```
    create_anyscale_node_groups = true
    ```
  EOT
  type        = bool
  default     = true
}

variable "eks_anyscale_node_groups" {
  description = <<-EOT
    (Optional) A list of Anyscale EKS Node Group configurations.

    A list of built in taints supported by Anyscale:
    {
      key    = "node.anyscale.com/capacity-type"
      value  = "ANY"
      effect = "NO_SCHEDULE"
    },
    {
      key    = "node.anyscale.com/capacity-type"
      value  = "SPOT"
      effect = "NO_EXECUTE"
    },
    {
      key    = "node.anyscale.com/accelerator-type"
      value  = "GPU"
      effect = "PREFER_NO_SCHEDULE"
    }

    ex:
    ```
    eks_anyscale_node_groups = [
      {
        name           = "anyscale-spot-cpu"
        instance_types = ["m5.large"]
        capacity_type  = "SPOT"
        labels         = {
          "node-type" = "anyscale"
        }
        tags           = {
          "test"        = true
          "environment" = "test"
        }
        ami_type       = "AL2_x86_64"
        disk_size      = 500 # Recommended to be at least 500GB. If not provided, will default to 500GB.
        scaling_config = {
          desired_size = 1 # Recommend setting this to 1 to prime the autoscaler cache with the instance types and GPU availability
          max_size     = 4
          min_size     = 0
        }
        update_config = {
          max_unavailable_percentage = 33
        }
        taints = [
          {
            key    = "node-type"
            value  = "anyscale"
            effect = "NO_SCHEDULE" # or "NO_EXECUTE" or "PREFER_NO_SCHEDULE"
          }
        ]
      },
      ...
    ]
    ```
  EOT
  type = list(
    object({
      name           = string
      instance_types = list(string)
      capacity_type  = string
      labels         = optional(map(string))
      tags           = optional(map(string))
      ami_type       = optional(string)
      disk_size      = optional(number)
      scaling_config = object({
        desired_size = number
        max_size     = number
        min_size     = number
      })
      update_config = optional(object({
        max_unavailable_percentage = optional(number)
        max_unavailable            = optional(number)
      }))
      taints = optional(list(
        object({
          key    = string
          value  = string
          effect = string
        })
      ))
    })
  )
  default = [

    {
      name = "anyscale-ondemand-cpu-16CPU-64GB"
      instance_types = [
        "m6a.4xlarge",
        "m5a.4xlarge",
        "m6i.4xlarge",
        "m5.4xlarge",
      ]
      capacity_type = "ON_DEMAND"
      ami_type      = "AL2_x86_64_GPU"
      tags          = {}
      scaling_config = {
        desired_size = 1
        max_size     = 50
        min_size     = 0
      }
      taints = [
        {
          key    = "node.anyscale.com/capacity-type"
          value  = "ANY"
          effect = "NO_SCHEDULE"
        }
      ]
    }
  ]
}
