# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# These variables must be set when using this module.
# ------------------------------------------------------------------------------

variable "security_group_ingress_allow_access_from_cidr_range" {
  description = <<-EOT
    (Required) Comma delimited string of IPv4 CIDR range to allow access to anyscale resources.
    This should be the list of CIDR ranges that have access to the clusters. Public or private IPs are supported.
    This is added to the security group and allows port 443 (https) and 22 (ssh) access.

    While not recommended, you can set this to `0.0.0.0/0` to allow access from anywhere.
    ex:
    ```
    security_group_ingress_allow_access_from_cidr_range = "10.0.1.0/24,24.1.24.24/32"
    ```
  EOT
  type        = string
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# These variables have defaults, but may be overridden.
# ------------------------------------------------------------------------------
variable "anyscale_deploy_env" {
  description = <<-EOF
    (Optional) Anyscale deployment environment.
    Used in resource names and tags.

    ex:
    ```
    anyscale_deploy_env = "production"
    ```
  EOF
  type        = string
  validation {
    condition = (
      var.anyscale_deploy_env == "production" || var.anyscale_deploy_env == "development" || var.anyscale_deploy_env == "test"
    )
    error_message = "The anyscale_deploy_env only allows `production`, `test`, or `development`"
  }
  default = "production"
}

variable "anyscale_cloud_id" {
  description = <<-EOF
    (Optional) Anyscale Cloud ID.

    This is used to lock down the cross account access role by Cloud ID. Because the Cloud ID is unique to each
    customer, this ensures that only the customer can access their own resources. The Cloud ID is not known until the
    Cloud is created, so this is an optional variable.

    ex:
    ```
    anyscale_cloud_id = "cld_abcdefghijklmnop1234567890"
    ```
  EOF
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

variable "anyscale_org_id" {
  description = <<-EOT
    (Optional) Anyscale Organization ID.

    This is used to lock down the cross account access role by Organization ID. Because the Organization ID is unique to each
    customer, this ensures that only the customer can access their own resources.

    ex:
    ```
    anyscale_org_id = "org_abcdefghijklmn1234567890"
    ```
  EOT
  type        = string
  default     = null
  validation {
    condition = (
      var.anyscale_org_id == null ? true : (
        length(var.anyscale_org_id) > 4 &&
        substr(var.anyscale_org_id, 0, 4) == "org_"
      )
    )
    error_message = "The anyscale_org_id value must start with \"org_\"."
  }
}

variable "tags" {
  description = <<-EOT
    (Optional) A map of tags.

    A map of default tags to be added to all resources that accept tags.
    Resource dependent tags will be appended to this list.

    ex:
    ```
    tags = {
      application = "Anyscale",
      environment = "prod"
    }
    ```
  EOT
  type        = map(string)
  default     = {}
}

variable "common_prefix" {
  description = <<-EOT
    (Optional) Common prefix.

    A common prefix to add to resources created (where prefixes are allowed).
    If paired with `use_common_name`, this will apply to all resources.
    If this is not paired with `use_common_name`, this applies to:
      - S3 Buckets
      - IAM Resources
      - Security Groups
    Resource specific prefixes override this variable.
    Max length is 30 characters.

    ex:
    ```
    common_prefix = "anyscale-"
    ```
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
    (Optional) Use a common name.

    Determines if a standard name should be used across all resources.
    If set to true and `common_prefix` is also provided, the `common_prefix` will be used prefixed to a common name.
    If set to true and `common_prefix` is not provided, the prefix will be `anyscale-`
    If set to true, this will also use a random suffix to avoid name collisions.

    ex:
    ```
    use_common_name = true
    ```
  EOT
  type        = bool
  default     = false
}

variable "random_name_suffix_length" {
  description = <<-EOT
    (Optional) Random name suffix length.

    Determines the random suffix length that is used to generate a common name.
    Certain AWS resources have a hard limit on name lengths and this will allow
    the ability to control how many characters are added as a suffix.
    Must be >= 2 and <= 30.

    ex:
    ```
    random_name_suffix_length = 6
    ```
  EOT
  type        = number
  default     = 6
  validation {
    condition     = try(var.random_name_suffix_length >= 2, var.random_name_suffix_length <= 30, false)
    error_message = "random_name_suffix_length must either be >= 2 and <= 30"
  }
}

#--------------------------------------------
# VPC Variables
#--------------------------------------------
variable "existing_vpc_id" {
  description = <<-EOT
    (Optional) An existing VPC ID.

    If provided, this will skip creating resources a new VPC with the Anyscale VPC module.
    Subnet IDs are also required if this is provided.

    ex:
    ```
    existing_vpc_id = "vpc-1234567890"
    ```
  EOT
  type        = string
  default     = null
}

variable "existing_vpc_subnet_ids" {
  description = <<-EOT
    (Optional) Existing subnet IDs.

    If provided, this will skip creating a new VPC with the Anyscale VPC module.
    The variable `existing_vpc_id` also needs to be provided.

    ex:
    ```
    existing_vpc_subnet_ids = ["subnet-1234567890", "subnet-0987654321"]
    ```
  EOT
  type        = list(string)
  default     = []
}

variable "existing_vpc_private_route_table_ids" {
  description = <<-EOT
    (Optional) Existing VPC Private Route Table IDs.

    If provided, this will map new private subnets to these route table IDs.
    If no new subnets are created, these route tables will be used to create VPC Endpoint(s).

    ex:
    ```
    existing_vpc_private_route_table_ids = ["rtb-1234567890", "rtb-0987654321"]
    ```
  EOT
  type        = list(string)
  default     = []
}

variable "existing_vpc_public_route_table_ids" {
  description = <<-EOT
    (Optional) Existing VPC Public Route Table IDs.

    If provided, these route tables will be used to create VPC Endpoint(s).

    ex:
    ```
    existing_vpc_public_route_table_ids = ["rtb-1234567890", "rtb-0987654321"]
    ```
  EOT
  type        = list(string)
  default     = []
}

variable "anyscale_vpc_name" {
  description = <<-EOT
    (Optional) VPC name.

    If provided, will create a VPC with this name.
    Defaults to `vpc_<anyscale_cloud_id>` in a local variable if not provided.

    ex:
    ```
    anyscale_vpc_name = "anyscale-vpc"
    ```
  EOT
  type        = string
  default     = null
}

variable "anyscale_vpc_cidr_block" {
  description = <<-EOT
    (Optional) The IPv4 CIDR block for the VPC.
    The CIDR block can be explicitly set or it can be derived from IPAM using `ipv4_netmask_length` & `ipv4_ipam_pool_id`.

    ex:
    ```
    anyscale_vpc_cidr_block = "10.0.0.0/16"
    ```
  EOT
  type        = string
  default     = "10.0.0.0/16"
}

variable "anyscale_vpc_public_subnets" {
  description = <<-EOT
    (Optional) A list of public subnets inside the VPC.

    If this variable is provided, public subnets will be created with these CIDR blocks.

    ex:
    ```
    anyscale_vpc_public_subnets = [
      "10.0.21.0/24",
      "10.0.22.0/24",
      "10.0.23.0/24"
    ]
    ```
  EOT
  type        = list(string)
  default     = []
}

variable "anyscale_vpc_public_subnet_tags" {
  description = <<-EOT
    (Optional) A map of tags for public subnets.

    Duplicate tags found in the `tags` or `anyscale_vpc_tags` variables will get duplicated on the resource.

    ex:
    ```
    anyscale_vpc_public_subnet_tags = {
      "purpose" : "networking",
      "criticality" : "critical"
    }
    ```
  EOT
  type        = map(string)
  default     = {}
}

variable "anyscale_vpc_private_subnets" {
  description = <<-EOT
    (Optional) A list of private subnets inside the VPC.

    If this variable is provided, private subnets will be created with these CIDR blocks.

    ex:
    ```
    anyscale_vpc_private_subnets = [
      "10.0.121.0/24",
      "10.0.122.0/24",
      "10.0.123.0/24"
    ]
    ```
  EOT
  type        = list(string)
  default     = []
}

variable "anyscale_vpc_private_subnet_tags" {
  description = <<-EOT
    (Optional) A map of tags for private subnets.

    Duplicate tags found in the `tags` or `anyscale_vpc_tags` variables will get duplicated on the resource.

    ex:
    ```
    anyscale_vpc_private_subnet_tags = {
      "purpose" : "networking",
      "criticality" : "critical"
    }
    ```
  EOT
  type        = map(string)
  default     = {}
}

variable "anyscale_vpc_tags" {
  description = <<-EOT
    (Optional) A map of tags for VPC resources.

    Duplicate tags found in the "tags" variable will get duplicated on the resource.

    ex:
    ```
    anyscale_vpc_tags = {
      "purpose" : "networking",
      "criticality" : "critical"
    }
    ```
  EOT
  type        = map(string)
  default     = {}
}

variable "anyscale_gateway_vpc_endpoints" {
  description = <<-EOT
    (Optional) A map of Gateway VPC Endpoints to provision into the VPC.

    This is a map of objects with the following attributes:
    - `name`: Short service name (either "s3" or "dynamodb")
    - `policy` = A policy (as JSON string) to attach to the endpoint that controls access to the service. May be `null` for full access.

    See the submodule variable for additional examples.

    It is Anyscale's recommendation to have an S3 VPC Endpoint to minimize S3 costs and maximize S3 performance.

    Set to an empty map `{}` to skip creating VPC Endpoints.

    ex:
    ```
    anyscale_gateway_vpc_endpoints = {
      "s3" = {
        name   = "s3"
        policy = null
      }
    }
    ```
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

# variable "create_memorydb_subnets" {
#   description = <<-EOT
#     (Optional) Create MemoryDB subnets.

#     If set to true, this will create MemoryDB subnets in the VPC. In this case, if the `create_memorydb_resources` is set to true, private subnets for MemoryDB will be created and used.
#     If set to false, this will not create MemoryDB subnets in the VPC. In this case, if the `create_memorydb_resources` is set to true, the private subnets will be used to create MemoryDB subnets.

#     Also requires `create_memorydb_resources` to be set to true.

#     ex:
#     ```
#     create_memorydb_subnets = true
#     ```
#   EOT
#   type        = bool
#   default     = false
# }

# variable "anyscale_vpc_memorydb_subnets" {
#   description = <<-EOT
#     (Optional) A list of MemoryDB subnets inside the VPC.

#     MemoryDB subnets will be created with these CIDR blocks. Also requires `create_memorydb_subnets` and `create_memorydb_resources` to both be set to true.

#     ex:
#     ```
#     anyscale_vpc_memorydb_subnets = [
#       "10.0.130.0/24",
#       "10.0.131.0/24",
#     ]
#     ```
#   EOT
#   type        = list(string)
#   default     = []
# }

# variable "anyscale_vpc_memorydb_subnet_tags" {
#   description = <<-EOT
#     (Optional) A map of tags for MemoryDB subnets.

#     Duplicate tags found in the `tags` or `anyscale_vpc_tags` variables will get duplicated on the resource.

#     ex:
#     ```
#     anyscale_vpc_memorydb_subnet_tags = {
#       "purpose" : "networking",
#       "criticality" : "critical"
#     }
#     ```
#   EOT
#   type        = map(string)
#   default     = {}
# }

#--------------------------------------------
# IAM Variables
#--------------------------------------------
# Cross Acct Access Role
variable "anyscale_iam_access_role_name" {
  description = <<-EOT
    (Optional, forces creation of new resource) The name of the Anyscale IAM access role.

    If left `null`, the name will default to `anyscale_iam_access_role_name_prefix` or `general_prefix`.
    If provided, overrides the `anyscale_iam_access_role_name_prefix` variable.

    ex:
    ```
    anyscale_iam_access_role_name = "anyscale-iam-crossacct-role"
    ```
  EOT
  type        = string
  default     = null
}

variable "anyscale_iam_access_role_name_prefix" {
  description = <<-EOT
    (Optional, forces creation of new resource) The prefix for the Anyscale IAM access role.

    If `anyscale_iam_access_role_name_prefix` is provided, it will override this variable.
    The variable `general_prefix` is a fall-back prefix if this is not provided.

    Default is `null` but is set to `anyscale-iam-role-` in a local variable.

    ex:
    ```
    anyscale_iam_access_role_name_prefix = "anyscale-crossacct-role-"
    ```
  EOT
  type        = string
  default     = null
}

variable "anyscale_access_role_description" {
  description = <<-EOT
    (Optional) The IAM role description for the Anysclae IAM access role.

    This role is used for cross account access from the Anyscale Controlplane to an AWS account and allows access to manage AWS resources.

    ex:
    ```
    anyscale_access_role_description = "Anyscale cross account access role"
    ```
  EOT
  type        = string
  default     = "Anyscale access role"
}

variable "anyscale_access_role_trusted_role_arns" {
  description = <<-EOT
    (Optional) Access Role Trusted Role ARNs.

    A list of ARNs of IAM roles that are allowed to assume the Anyscale IAM access role.
    Default is an empty list and the default in the `aws-anyscale-iam` sub-module is used.
    This variable should not be used unless directed by Anyscale.
  EOT
  type        = list(string)
  default     = []
}

variable "anyscale_access_steadystate_policy_name" {
  description = <<-EOT
    (Optional) Name for the Anyscale default steady state IAM policy.

    If left `null`, will default to `anyscale_access_steadystate_policy_prefix` or `general_prefix`.
    If provided, overrides the `anyscale_access_steadystate_policy_prefix` variable.

    ex:
    ```
    anyscale_access_steadystate_policy_name = "anyscale-steadystate-policy"
    ```
  EOT
  type        = string
  default     = null
}

variable "anyscale_access_steadystate_policy_prefix" {
  description = <<-EOT
    (Optional) Name prefix for the Anyscale default steady state IAM policy.

    If `anyscale_access_steadystate_policy_name` is provided, it will override this variable.
    The variable `general_prefix` is a fall-back prefix if this is not provided.
    Default is `null` but is set to `anyscale-steady_state-` in a local variable.

    ex:
    ```
    anyscale_access_steadystate_policy_prefix = "anyscale-steadystate-policy-"
    ```
  EOT
  type        = string
  default     = null
}

variable "anyscale_access_steadystate_policy_description" {
  description = <<-EOT
    (Optional) Anyscale steady state IAM policy description.

    ex:
    ```
    anyscale_access_steadystate_policy_description = "Anyscale Steady State IAM Policy which is used by the Anyscale IAM Access Role"
    ```
  EOT
  type        = string
  default     = "Anyscale Steady State IAM Policy which is used by the Anyscale IAM Access Role"
}

variable "anyscale_access_servicesv2_policy_name" {
  description = <<-EOT
    (Optional) Name for the Anyscale default servicesv2 IAM policy.

    If left `null`, will default to `anyscale_access_servicesv2_policy_prefix` or `general_prefix`.
    If provided, overrides the `anyscale_access_servicesv2_policy_prefix` variable.

    ex:
    ```
    anyscale_access_servicesv2_policy_name = "anyscale-servicesv2-policy"
    ```
  EOT
  type        = string
  default     = null
}

variable "anyscale_access_servicesv2_policy_prefix" {
  description = <<-EOT
    (Optional) Name prefix for the Anyscale default servicesv2 IAM policy.

    If `anyscale_access_servicesv2_policy_name` is provided, it will override this variable.
    The variable `general_prefix` is a fall-back prefix if this is not provided.
    Default is `null` but is set to `anyscale-servicesv2-` in a local variable.

    ex:
    ```
    anyscale_access_servicesv2_policy_prefix = "anyscale-servicesv2-policy-"
    ```
  EOT
  type        = string
  default     = null
}

variable "anyscale_access_servicesv2_policy_description" {
  description = <<-EOT
    (Optional) Anyscale servicesv2 IAM policy description.

    ex:
    ```
    anyscale_access_servicesv2_policy_description = "Anyscale Services v2 IAM Policy which is used by the Anyscale IAM Access Role"
    ```
  EOT
  type        = string
  default     = "Anyscale Services v2 IAM Policy which is used by the Anyscale IAM Access Role"
}

# Anyscale Access Role Custom Policy
variable "anyscale_accessrole_custom_policy_name" {
  description = <<-EOT
    (Optional) Name for an Anyscale custom IAM policy.

    If left `null`, will default to `anyscale_custom_policy_name_prefix` or `general_prefix`.
    If provided, overrides the `anyscale_accessrole_custom_policy_name_prefix` variable.

    ex:
    ```
    anyscale_accessrole_custom_policy_name = "anyscale-custom-policy"
    ```
  EOT
  type        = string
  default     = null
}

variable "anyscale_accessrole_custom_policy_name_prefix" {
  description = <<-EOT
    (Optional) Name prefix for the Anyscale custom IAM policy.
    If `anyscale_accessrole_custom_policy_name` is provided, it will override this variable.
    The variable `general_prefix` is a fall-back prefix if this is not provided.
    Default is `null` but is set to `anyscale-crossacct-custom-policy-` in a local variable.

    ex:
    ```
    anyscale_accessrole_custom_policy_name_prefix = "anyscale-custom-policy-"
    ```
  EOT
  type        = string
  default     = null
}

variable "anyscale_accessrole_custom_policy_description" {
  description = <<-EOT
    (Optional) Anyscale IAM custom policy description.

    ex:
    ```
    anyscale_accessrole_custom_policy_description = "Anyscale custom IAM policy"
    ```
  EOT
  type        = string
  default     = "Anyscale custom IAM policy"
}

variable "anyscale_accessrole_custom_policy" {
  description = <<-EOT
    (Optional) Anyscale custom IAM policy.

    This policy will be applied in addition to the default policies added to the Anyscale Access IAM Role.

    Note: Any customizations to the IAM Role need to be carefully tested and Anyscale is not
    responsible for any problems that may occur due to misconfiguring the policy and/or Anyscale Access Role.

    Must be a valid IAM policy.

    ex:
    ```
    anyscale_accessrole_custom_policy = {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "AllowAllActions",
          "Effect": "Allow",
          "Action": "*",
          "Resource": "*"
        }
      ]
    }
  EOT
  type        = string
  default     = null
}

# Cluster Node Role
variable "anyscale_iam_cluster_node_role_name" {
  description = <<-EOT
    (Optional, forces creation of new resource) The name of the Anyscale IAM cluster node role.

    If left `null`, will default to `anyscale_iam_access_role_name_prefix` or `general_prefix`.
    If provided, overrides the `anyscale_iam_cluster_node_role_name_prefix` variable.

    ex:
    ```
    anyscale_iam_cluster_node_role_name = "anyscale-cluster-node-role"
    ```
  EOT
  type        = string
  default     = null
}
variable "anyscale_iam_cluster_node_role_name_prefix" {
  description = <<-EOT
    (Optional, forces creation of new resource) The prefix of the Anyscale Cluster Node IAM role.

    If `anyscale_iam_cluster_node_role_name` is provided, it will override this variable.
    The variable `general_prefix` is a fall-back prefix if this is not provided.
    Default is `null` but is set to `anyscale-cluster-node-` in a local variable.

    ex:
    ```
    anyscale_iam_cluster_node_role_name_prefix = "anyscale-cluster-node-role-"
    ```
  EOT
  type        = string
  default     = null
}

variable "anyscale_cluster_node_role_description" {
  description = <<-EOT
    (Optional) The IAM Role description for the Anyscale Cluster Node Role.

    This role is used by compute resources to access resources within an AWS account.

    ex:
    ```
    anyscale_cluster_node_role_description = "Anyscale cluster node role"
    ```
  EOT
  type        = string
  default     = "Anyscale cluster node role"
}

variable "anyscale_cluster_node_custom_policy_name" {
  description = <<-EOT
    (Optional) Name for the Anyscale cluster node custom IAM policy.

    If left `null`, will default to `anyscale_cluster_node_custom_policy_prefix` or `general_prefix`.
    If provided, overrides the `anyscale_cluster_node_custom_policy_name_prefix` variable.

    ex:
    ```
    anyscale_cluster_node_custom_policy_name = "anyscale-clusternode-custom-policy"
    ```
  EOT
  type        = string
  default     = null
}

variable "anyscale_cluster_node_custom_policy_prefix" {
  description = <<-EOT
    (Optional) Name prefix for the Anyscale cluster node custom IAM policy.

    If `anyscale_cluster_node_custom_policy_name` is provided, it will override this variable.
    The variable `general_prefix` is a fall-back prefix if this is not provided.
    Default is `null` but is set to `anyscale-clusternode-custom-policy-` in a local variable.

    ex:
    ```
    anyscale_cluster_node_custom_policy_prefix = "anyscale-clusternode-custom-policy-"
    ```
  EOT
  type        = string
  default     = null
}

variable "anyscale_cluster_node_custom_policy_description" {
  description = <<-EOT
    (Optional) Anyscale IAM cluster node custom policy description.

    ex:
    ```
    anyscale_cluster_node_custom_policy_description = "Anyscale cluster node custom IAM policy"
    ```
  EOT
  type        = string
  default     = "Anyscale cluster node custom IAM policy"
}

variable "anyscale_cluster_node_custom_policy" {
  description = <<-EOT
    (Optional) Anyscale cluster node custom IAM policy.

    This policy will be applied in addition to the default policies added to the Cluster Node Role.

    Note: Any customizations to the IAM Role need to be carefully tested and Anyscale is not
    responsible for any problems that may occur due to misconfiguring the policy and/or Cluster Role.
    Must be a valid IAM policy.

    ex:
    ```
    anyscale_cluster_node_custom_policy = {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "AllowAllActions",
          "Effect": "Allow",
          "Action": "*",
          "Resource": "*"
        }
      ]
    }
    ```
  EOT
  type        = string
  default     = null
}

variable "anyscale_cluster_node_managed_policy_arns" {
  description = <<-EOT
    (Optional) List of IAM policy ARNs to attach to the role.

    This allows custom or managed policies to be attached to the Anyscale Cluster Role which can be used to grant additional permissions.

    ex:
    ```
    anyscale_cluster_node_managed_policy_arns = [
      "arn:aws:iam::aws:policy/AmazonSQSReadOnlyAccess",
      "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
    ]
    ```
  EOT
  type        = list(string)
  default     = []
}

variable "create_cluster_node_cloudwatch_policy" {
  description = <<-EOT
    (Optional) Create the Anyscale Cluster Node Cloudwatch Policy
    Determines whether to create the CloudWatch IAM policy for the cluster node role.

    ex:
    ```
    create_cluster_node_cloudwatch_policy = true
    ```
  EOT
  type        = bool
  default     = false
}

variable "anyscale_cluster_node_cloudwatch_policy_description" {
  description = <<-EOT
    (Optional)
    Anyscale IAM cluster node CloudWatch policy description.

    ex:
    ```
    anyscale_cluster_node_cloudwatch_policy_description = "Anyscale cluster node CloudWatch IAM policy"
    ```
  EOT
  type        = string
  default     = "Anyscale cluster node CloudWatch IAM policy"
}

variable "anyscale_cluster_node_cloudwatch_policy_name" {
  description = <<-EOT
    (Optional) Name for the Anyscale cluster node CloudWatch IAM policy.

    If left `null`, will default to `anyscale_cluster_node_cloudwatch_policy_prefix` or `general_prefix`.
    If provided, overrides the `anyscale_cluster_node_cloudwatch_policy_name_prefix` variable.

    ex:
    ```
    anyscale_cluster_node_cloudwatch_policy_name = "anyscale-cluster-node-cloudwatch-policy"
    ```
  EOT
  type        = string
  default     = null
}

variable "anyscale_cluster_node_cloudwatch_policy_prefix" {
  description = <<-EOT
    (Optional) Name prefix for the Anyscale cluster node CloudWatch IAM policy.

    If `anyscale_cluster_node_cloudwatch_policy_name` is provided, it will override this variable.
    The variable `general_prefix` is a fall-back prefix if this is not provided.
    Default is `null` but is set to `anyscale-cluster-node-cloudwatch-policy-` in a local variable.

    ex:
    ```
    anyscale_cluster_node_cloudwatch_policy_prefix = "anyscale-cluster-node-cloudwatch-policy-"
    ```
  EOT
  type        = string
  default     = null
}

#- Secrets Manager Policy
variable "anyscale_cluster_node_byod_secrets_policy_name" {
  description = <<-EOT
    (Optional) Name for the Anyscale cluster node Secrets IAM policy.

    If left `null`, will default to `anyscale_cluster_node_secrets_policy_prefix` or `general_prefix`.
    If provided, overrides the `anyscale_cluster_node_secrets_policy_prefix` variable.

    ex:
    ```
    anyscale_cluster_node_secrets_policy_name = "anyscale-cluster-node-secrets-policy"
    #checkov:skip=CKV_SECRET_6:Secret Policy is not a secret'
    ```
  EOT
  type        = string
  default     = null
}
variable "anyscale_cluster_node_byod_secrets_policy_prefix" {
  description = <<-EOT
    (Optional) Name prefix for the Anyscale cluster node Secrets IAM policy.

    If `anyscale_cluster_node_secrets_policy_name` is provided, it will override this variable.
    The variable `general_prefix` is a fall-back prefix if this is not provided.
    Default is `null` but is set to `anyscale-cluster-node-secrets-` in a local variable.

    ex:
    ```
    anyscale_cluster_node_secrets_policy_prefix = "anyscale-cluster-node-secrets-"
    #checkov:skip=CKV_SECRET_6:Secret Name Prefix is not a secret'
    ```
  EOT
  type        = string
  default     = null
}

variable "anyscale_cluster_node_byod_secrets_policy_description" {
  description = <<-EOT
    (Optional) Anyscale IAM cluster node Secrets policy description.

    ex:
    ```
    anyscale_cluster_node_secrets_policy_description = "Anyscale Cluster Node Secrets Policy"
    ```
  EOT
  type        = string
  default     = "Anyscale Cluster Node Secrets Policy"
}
variable "anyscale_cluster_node_byod_secret_arns" {
  description = <<-EOT
    (Optional) A list of Secrets Manager ARNs.
    The Secrets Manager secret ARNs that the cluster node role needs access to for BYOD clusters.

    ex:
    ```
    anyscale_cluster_node_secret_arns = [
      "arn:aws:secretsmanager:us-east-1:123456789012:secret:my-secret-1",
      "arn:aws:secretsmanager:us-east-1:123456789012:secret:my-secret-2",
    ]
    ```
  EOT
  type        = list(string)
  default     = []
}

variable "anyscale_cluster_node_byod_secret_kms_arn" {
  description = <<-EOT
    (Optional) The KMS key ARN that the Secrets Manager secrets are encrypted with.
    This is only used if `anyscale_cluster_node_byod_secret_arns` is also provided.

    ex:
    ```
    anyscale_cluster_node_secret_arns = [
      "arn:aws:secretsmanager:us-east-1:123456789012:secret:my-secret-1",
      "arn:aws:secretsmanager:us-east-1:123456789012:secret:my-secret-2",
    ]
    anyscale_cluster_node_secret_kms_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
    ```
  EOT
  type        = string
  default     = null
}
variable "anyscale_cluster_node_byod_custom_secrets_policy" {
  description = <<-EOT
  (Optional) A custom IAM policy to attach to the cluster node role with access to the Secrets Manager secrets.
  If provided, this will be used instead of generating a policy automatically.

  ex:
  ```
  anyscale_cluster_node_byod_custom_secrets_policy = {
      "Version": "2012-10-17",
      "Statement": [
        "Sid": "SecretsManagerGetSecretValue",
        "Effect": "Allow",
        "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": [
        "arn:aws:secretsmanager:us-east-1:123456789012:secret:my-secret-1",
      ]
    }
  EOT
  type        = string
  default     = null
}

#- S3 Policy
variable "anyscale_iam_s3_policy_name" {
  description = <<-EOT
    (Optional) Name for the Anyscale S3 access IAM policy.

    If left `null`, will default to `anyscale_iam_s3_policy_name_prefix` or `general_prefix`.
    If provided, overrides the `anyscale_iam_s3_policy_name_prefix` variable.

    ex:
    ```
    anyscale_iam_s3_policy_name = "anyscale-iam-s3-policy"
    ```
  EOT
  type        = string
  default     = null
}
variable "anyscale_iam_s3_policy_name_prefix" {
  description = <<-EOT
    (Optional) Name prefix for the Anyscale S3 access IAM policy.

    If `anyscale_iam_s3_policy_name` is provided, it will override this variable.
    The variable `general_prefix` is a fall-back prefix if this is not provided.
    Default is `null` but is set to `anyscale-iam-s3-` in a local variable.

    ex:
    ```
    anyscale_iam_s3_policy_name_prefix = "anyscale-iam-s3-"
    ```
  EOT
  type        = string
  default     = null
}
variable "anyscale_iam_s3_policy_description" {
  description = <<-EOT
    (Optional) Anyscale S3 access IAM policy description.

    ex:
    ```
    anyscale_iam_s3_policy_description = "Anyscale S3 Access IAM Policy"
    ```
  EOT
  type        = string
  default     = "Anyscale S3 Access IAM Policy"
}

variable "anyscale_iam_tags" {
  description = <<-EOT
    (Optional) A map of tags for IAM resources.

    Duplicate tags found in the "tags" variable will get duplicated on the resources.

    ex:
    ```
    anyscale_iam_tags = {
      "purpose" : "iam",
      "criticality" : "critical"
    }
    ```
  EOT
  type        = map(string)
  default     = {}
}

#--------------------------------------------
# Security Group Variables
#--------------------------------------------
variable "security_group_name" {
  description = <<-EOT
    (Optional) The name for the security group.

    If left `null`, will default to `security_group_name_prefix` or `general_prefix`.
    If provided, overrides `security_group_name_prefix`.

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
    The variable `general_prefix` is a fall-back prefix if this is not provided.
    Default is `null` but is set to `anyscale-security-group-` in a local variable.

    ex:
    ```
    security_group_name_prefix = "anyscale-security-group-"
    ```
  EOT
  type        = string
  default     = null
}

variable "security_group_create_anyscale_public_ingress" {
  type        = bool
  description = <<-EOT
    (Optional) Determines if public ingress rules should be created.

    ex:
    ```
    security_group_create_anyscale_public_ingress = true
    ```
  EOT
  default     = false
}

variable "security_group_ingress_with_existing_security_groups_map" {
  type        = list(map(string))
  description = <<-EOT
    (Optional) List of security groups and rules to allow ingress from.

    If this is provided, the security groups will be added to the ingress rules with the
    ports in the `rule` section.

    ex:
    ```
    security_group_ingress_with_existing_security_groups_map = [
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

    ex:
    ```
    security_group_override_ingress_from_cidr_map = [
      {
        rule        = "https-443-tcp"
        cidr_blocks = "10.100.10.10/32"
      },
      { rule = "nfs-tcp" },
      {
        rule        = "ssh-tcp"
        cidr_blocks = "10.100.10.10/32"
      }
    ]
  EOT
  default     = []
}

variable "anyscale_securitygroup_tags" {
  description = <<-EOT
    (Optional) A map of tags for Security Group resources.

    Duplicate tags found in the "tags" variable will get duplicated on the resource.

    ex:
    ```
    anyscale_securitygroup_tags = {
      "purpose" : "security",
      "criticality" : "critical"
    }
    ```
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
    (Optional) Elastic file system name.

    Will default to `efs_anyscale` if this var `null` and anyscale_cloud_id is also `null`.

    ex:
    ```
    anyscale_efs_name = "anyscale-efs"
    ```
  EOT
  type        = string
  default     = null
}

variable "efs_creation_token" {
  description = <<-EOT
    (Optional) A unique token for EFS creation.

    The token is used as reference when creating the Elastic File System to ensure idempotent file system creation.
    Default is `null` which forces Terraform to generate it.

    ex:
    ```
    efs_creation_token = "anyscale-efs-token-1234567890"
    ```
  EOT
  type        = string
  default     = null
}

variable "efs_lifecycle_transition_to_ia" {
  description = <<-EOT
    (Optional) EFS Lifecycle Transition to Infrequent Access.

    Indicates how long it takes to transition files to Infrequent Access storage class.
    No value, or an empty list, means never.
    Must either be an empty list or one of "AFTER_7_DAYS", "AFTER_14_DAYS", "AFTER_30_DAYS", "AFTER_60_DAYS", "AFTER_90_DAYS".
    Default is `AFTER_60_DAYS` which will transition to IA after 60 days.

    ex:
    ```
    efs_lifecycle_transition_to_ia = ["AFTER_60_DAYS"]
    ```
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
    (Optional) EFS Lifecycle Transition to Primary Storage.

    Indicates the policy used to transition a file from Infrequent Access (IA) storage to primary storage.
    Must either be an empty list or `AFTER_1_ACCESS`.

    ex:
    ```
    efs_lifecycle_transition_to_primary_storage_class = ["AFTER_1_ACCESS"]
    ```
  EOT
  default     = ["AFTER_1_ACCESS"]
  validation {
    condition = (
      length(var.efs_lifecycle_transition_to_primary_storage_class) == 1 ? contains(["AFTER_1_ACCESS"], var.efs_lifecycle_transition_to_primary_storage_class[0]) : length(var.efs_lifecycle_transition_to_primary_storage_class) == 0
    )
    error_message = "Var `efs_lifecycle_transition_to_primary_storage_class` must either be empty list or \"AFTER_1_ACCESS\"."
  }
}

variable "efs_kms_key_id" {
  description = <<-EOT
    (Optional) The KMS key ID used to encrypt the Elastic File System.

    If not provided, the default AWS managed key will be used.

    ex:
    ```
    efs_kms_key_id = "1234abcd-12ab-34cd-56ef-1234567890ab"
    ```
  EOT
  type        = string
  default     = null
}

variable "anyscale_efs_tags" {
  description = <<-EOT
    (Optional) A map of tags for EFS resources.

    Duplicate tags found in the "tags" variable will get duplicated on the resource.

    ex:
    ```
    anyscale_efs_tags = {
      "purpose" : "storage",
      "criticality" : "critical"
    }
    ```
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
    (Optional) The name of an existing S3 bucket that you'd like to use.

    Please make sure that it meets the minimum requirements for Anyscale including:
      - Bucket Policy
      - CORS Policy
      - Encryption configuration

    ex:
    ```
    existing_s3_bucket_arn = "arn:aws:s3:::anyscale-s3-bucket"
    ```
  EOT
  type        = string
  default     = null
}

variable "anyscale_s3_bucket_name" {
  description = <<-EOT
    (Optional - forces new resource) S3 Bucket Name.

    The name of the bucket used to store Anyscale related logs and other shared resources.
    If left `null`, will default to `anyscale_s3_bucket_prefix` or `general_prefix`.
    If provided, overrides the `anyscale_s3_bucket_prefix` variable.

    ex:
    ```
    anyscale_s3_bucket_name = "anyscale-s3-bucket"
    ```
  EOT
  type        = string
  default     = null
}

variable "anyscale_s3_bucket_prefix" {
  description = <<-EOT
    (Optional - forces new resource) S3 Bucket name prefix.

    Creates a unique bucket name beginning with the specified prefix.
    If `anyscale_s3_bucket_name` is provided, it will override this variable.
    The variable `general_prefix` is a fall-back prefix if this is not provided.
    Default is `null` but is set to `anyscale-` in a local variable.

    ex:
    ```
    anyscale_s3_bucket_prefix = "anyscale-s3-bucket-"
    ```
  EOT
  type        = string
  default     = null
}

variable "anyscale_s3_server_side_encryption" {
  description = <<-EOT
    (Optional) S3 Bucket Server Side Encryption.

    Configuration to enforce server side encryption (KMS or AES256).
    If you are using KMS, you must proivde the KMS Key ID.

    ex using KMS:
    ```
    anyscale_s3_server_side_encryption = {
      kms_master_key_id = "1234abcd-12ab-34cd-56ef-1234567890ab"
      sse_algorithm     = "aws:kms"
    }
    ```

    ex using AES256:
    ```
    anyscale_s3_server_side_encryption = {
      sse_algorithm = "AES256"
    }
    ```
  EOT
  type        = map(string)
  default = {
    sse_algorithm = "AES256"
  }
}

variable "anyscale_s3_force_destroy" {
  description = <<-EOT
    (Optional) S3 Bucket Force Destroy.

    Deterimines if objects from the bucket can be destroyed without error.
    If set to true and bucket is destroyed, objects are not recoverable.

    Note: With the default of `false`, you need to empty the bucket if there are objects before `terraform destroy` can be completed succesfully.

    ex:
    ```
    anyscale_s3_force_destroy = true
    ```
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
    (Optional) A valid bucket policy in JSON.

    This will be an additional S3 bucket policy to the required Anyscale policy.
    For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide.
    And for more additional examples, please look at the s3-policy sub-module examples folder.

    ex:
    ```
    data "aws_iam_policy_document" "bucket_policy" {
    statement {
        principals {
          type        = "AWS"
          identifiers = [aws_iam_role.this.arn]
        }

      actions = [
        "s3:ListBucket",
      ]

      resources = [
        "module.aws_anyscale_s3.s3_bucket_arn,
      ]
    }
    anyscale_custom_s3_policy = data.aws_iam_policy_document.bucket_policy.json
    ```
  EOT
  type        = string
  default     = null
}

variable "anyscale_s3_tags" {
  description = <<-EOT
    (Optional) A map of tags for S3 resources.

    Duplicate tags found in the "tags" variable will get duplicated on the resource.

    ex:
    ```
    anyscale_iam_tags = {
      "purpose" : "storage",
      "criticality" : "critical"
    }
    ```
  EOT
  type        = map(string)
  default     = {}
}

variable "anyscale_s3_lifecycle_rule" {
  description = <<-EOT
    (Optional) S3 Lifecycle Rule.

    List of maps containing configuration of object lifecycle management.

    ex:
    ```
    anyscale_s3_lifecycle_rule = [
      {
        id      = "log"
        enabled = true
        filter = {
          prefix = "log1/"
        }
        transition = [
          {
            days          = 30
            storage_class = "ONEZONE_IA"
          }, {
            days          = 60
            storage_class = "GLACIER"
          }
        ]
        noncurrent_version_transition = [
          {
            days          = 30
            storage_class = "STANDARD_IA"
          },
        ]
      }
    ]
    ```
    Default is an empty list.
  EOT
  type        = any
  default     = []
}

#--------------------------------------------
# MemoryDB Variables
#--------------------------------------------
variable "create_memorydb_resources" {
  description = <<-EOT
    (Optional) Determines whether to create the MemoryDB resources.

    ex:
    ```
    create_memorydb_resources = true
    ```
  EOT
  type        = bool
  default     = false
}

variable "anyscale_memorydb_tags" {
  description = <<-EOT
    (Optional) A map of tags for MemoryDB resources.

    Duplicate tags found in the "tags" variable will get duplicated on the resource.

    ex:
    ```
    anyscale_memorydb_tags = {
      "purpose" : "memorydb",
      "criticality" : "critical"
    }
    ```
    Default is an empty map.
  EOT
  type        = map(string)
  default     = {}
}

variable "anyscale_memorydb_cluster_name" {
  description = <<-EOT
    (Optional) The name of the MemoryDB cluster.

    If left `null`, will default to `anyscale_memorydb_cluster_name` or `general_prefix`.
    If provided, overrides the `anyscale_memorydb_cluster_name` variable.

    ex:
    ```
    anyscale_memorydb_cluster_name = "anyscale-memorydb-cluster"
    ```
  EOT
  type        = string
  default     = null
}
variable "anyscale_memorydb_cluster_name_prefix" {
  description = <<-EOT
    (Optional) The prefix of the MemoryDB cluster.

    If `anyscale_memorydb_cluster_name` is provided, it will override this variable.
    The variable `general_prefix` is a fall-back prefix if this is not provided.
    Default is `null` but is set to `anyscale-memorydb-cluster-` in a local variable.

    ex:
    ```
    anyscale_memorydb_cluster_name_prefix = "anyscale-memorydb-cluster-"
    ```
  EOT
  type        = string
  default     = null
}

variable "anyscale_memorydb_cluster_description" {
  description = <<-EOT
    (Optional) The description of the MemoryDB cluster.

    ex:
    ```
    anyscale_memorydb_cluster_description = "Anyscale MemoryDB cluster"
    ```
  EOT
  type        = string
  default     = "Anyscale MemoryDB Cluster"
}

variable "anyscale_memorydb_parameter_group_name" {
  description = <<-EOT
    (Optional) The name of the MemoryDB parameter group.

    If left `null`, will default to `anyscale_memorydb_parameter_group_name_prefix` or `general_prefix`.
    If provided, overrides the `anyscale_memorydb_parameter_group_name_prefix` variable.

    ex:
    ```
    memorydb_parameter_group_name = "anyscale-memorydb-parameter-group"
    ```
  EOT
  type        = string
  default     = null
}

variable "anyscale_memorydb_parameter_group_name_prefix" {
  description = <<-EOT
    (Optional) The prefix of the MemoryDB parameter group.

    If `anyscale_memorydb_parameter_group_name` is provided, it will override this variable.
    The variable `general_prefix` is a fall-back prefix if this is not provided.
    Default is `null` but is set to `anyscale-memorydb-parameter-group-` in a local variable.

    ex:
    ```
    anyscale_memorydb_parameter_group_name_prefix = "anyscale-memorydb-parameter-group-"
    ```
  EOT
  type        = string
  default     = null
}

variable "anyscale_memorydb_parameter_group_description" {
  description = <<-EOT
    (Optional) The description of the MemoryDB parameter group.

    ex:
    ```
    anyscale_memorydb_parameter_group_description = "Anyscale MemoryDB Parameter Group"
    ```
  EOT
  type        = string
  default     = "Anyscale MemoryDB Parameter Group"
}

variable "anyscale_memorydb_subnet_group_name" {
  description = <<-EOT
    (Optional) The name of the MemoryDB subnet group.

    If left `null`, will default to `anyscale_memorydb_subnet_group_name_prefix` or `general_prefix`.
    If provided, overrides the `memorydb_subnet_group_name_prefix` variable.

    ex:
    ```
    anyscale_memorydb_subnet_group_name = "anyscale-memorydb-subnet-group"
    ```
  EOT
  type        = string
  default     = null
}

variable "anyscale_memorydb_subnet_group_name_prefix" {
  description = <<-EOT
    (Optional) The prefix of the MemoryDB subnet group.

    If `anyscale_memorydb_subnet_group_name` is provided, it will override this variable.
    The variable `general_prefix` is a fall-back prefix if this is not provided.
    Default is `null` but is set to `memorydb-subnet-group-` in a local variable.

    ex:
    ```
    anyscale_memorydb_subnet_group_name_prefix = "anyscale-memorydb-subnet-group-"
    ```
  EOT
  type        = string
  default     = null
}

variable "anyscale_memorydb_subnet_group_description" {
  description = <<-EOT
    (Optional) The description of the MemoryDB subnet group.

    ex:
    ```
    anyscale_memorydb_subnet_group_description = "Anyscale MemoryDB Subnet Group"
    ```
  EOT
  type        = string
  default     = "Anyscale MemoryDB Subnet Group"
}

variable "anyscale_memorydb_acl_name" {
  description = <<-EOT
    (Optional) The name of the MemoryDB ACL.

    If left `null`, will default to `anyscale_memorydb_acl_name_prefix` or `general_prefix`.
    If provided, overrides the `anyscale_memorydb_acl_name_prefix` variable.

    ex:
    ```
    anyscale_memorydb_acl_name = "anyscale-memorydb-acl"
    ```
  EOT
  type        = string
  default     = null
}

variable "anyscale_memorydb_acl_name_prefix" {
  description = <<-EOT
    (Optional) The prefix of the MemoryDB ACL.

    If `anyscale_memorydb_acl_name` is provided, it will override this variable.
    The variable `general_prefix` is a fall-back prefix if this is not provided.
    Default is `null` but is set to `memorydb-acl-` in a local variable.

    ex:
    ```
    anyscale_memorydb_acl_name_prefix = "anyscale-memorydb-acl-"
    ```
  EOT
  type        = string
  default     = null
}
