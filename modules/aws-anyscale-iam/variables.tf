# ------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables must be set when using this module.
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These variables have defaults, but may be overridden.
# ------------------------------------------------------------------------------
variable "anyscale_cloud_id" {
  description = "Anyscale Cloud ID"
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
  description = "Anyscale Organization ID"
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
  description = <<-EOT
    (Optional, forces creation of new resource) The name of the Anyscale IAM access role.

    Overrides/conflicts with `anyscale_access_role_name_prefix`.

    ex:
    ```
    anyscale_access_role_name = "anyscale-iam-role"
    ```
  EOT

  type    = string
  default = null
}

variable "anyscale_access_role_name_prefix" {
  description = <<-EOT
    (Optional, forces creation of new resource) The prefix of the Anyscale IAM access role.

    Conflicts with anyscale_access_role_name.

    ex:
    ```
    anyscale_access_role_name_prefix = "anyscale-iam-role-"
    ```
  EOT
  type        = string
  default     = "anyscale-iam-role-"
}

variable "anyscale_access_role_path" {
  description = <<-EOT
    (Optional) The path to the IAM role.

    ex:
    ```
    anyscale_access_role_path = "/"
    ```
  EOT
  type        = string
  default     = "/"
}

variable "anyscale_access_role_description" {
  description = <<-EOT
    (Optional) IAM Role description. Default is `null`.

    ex:
    ```
    anyscale_access_role_description = "Anyscale IAM Role"
    ```
  EOT
  type        = string
  default     = null
}

variable "role_permissions_boundary_arn" {
  description = <<-EOT
    (Optional) Permissions boundary ARN to use for IAM role.

    ex:
    ```
    role_permissions_boundary_arn = "arn:aws:iam::123456789012:policy/MyPermissionsBoundary"
    ```
  EOT
  type        = string
  default     = null
}

variable "anyscale_default_trusted_role_arns" {
  description = <<-EOT
    (Optional) ARNs of AWS entities who can assume these roles.

    If `anyscale_trusted_role_arns` is provided, it will override this variable.

    Default is the AWS account for Anyscale Production.
  EOT
  type        = list(string)
  default     = ["arn:aws:iam::525325868955:root"]
}
variable "anyscale_trusted_role_arns" {
  description = <<-EOT
    (Optional) ARNs of AWS entities who can assume these roles.

    If this variable is provided, it will override `anyscale_default_trusted_role_arns`.

    ex:
    ```
    anyscale_trusted_role_arns = ["arn:aws:iam::123456789012:role/role-name"]
    ```
  EOT
  type        = list(string)
  default     = []
}

variable "anyscale_trusted_role_sts_externalid" {
  description = "(Optional) STS ExternalId condition values to use with a role. Default is an empty list."
  type        = any
  default     = []
}

variable "anyscale_external_id" {
  description = <<-EOT
    (Optional) External ID to use for the trust policy.

    If provided, this will be used instead of the cloud ID.
    It must start with the Organization ID (e.g. `org_1234567890abcdef-<additional-external-id>`)

    ex:
    ```
    anyscale_external_id = "org_1234567890abcdef-1234567890abcdef"
    ```
  EOT
  type        = string
  default     = null
  validation {
    condition = (
      var.anyscale_external_id == null ? true : (
        length(var.anyscale_external_id) > 4 &&
        substr(var.anyscale_external_id, 0, 4) == "org_"
      )
    )
    error_message = "The anyscale_external_id value must start with your Anyscale Organization ID (e.g. \"org_1234567890abcdef\")."
  }
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

variable "create_elb_service_linked_role" {
  description = <<-EOT
    (Optional) Determines if the ELB service linked role is created.

    ex:
    ```
    create_elb_service_linked_role = true
    ```
  EOT
  type        = bool
  default     = true
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
# Cluster Node Role (Data Plane)
#  & Instance Profile
# ------------------
variable "create_cluster_node_instance_profile" {
  description = <<-EOT
    (Optional) Determines whether to create an instance profile role.

    ex:
    ```
    create_cluster_node_instance_profile = true
    ```
  EOT
  type        = bool
  default     = true
}

variable "anyscale_cluster_node_role_name" {
  description = <<-EOT
    (Optional, forces creation of new resource) The name of the Anyscale IAM cluster node role.

    ex:
    ```
    anyscale_cluster_node_role_name = "anyscale-cluster-node"
    ```
  EOT
  type        = string
  default     = null
}

variable "anyscale_cluster_node_role_name_prefix" {
  description = <<-EOT
    (Optional, forces creation of new resource) The prefix of the Anyscale Cluster Node IAM role.

    If `anyscale_cluster_node_role_name` is provided, it will override this variable.

    ex:
    ```
    anyscale_cluster_node_role_name_prefix = "anyscale-cluster-node-"
    ```
  EOT
  type        = string
  default     = "anyscale-cluster-node-"
}

variable "anyscale_cluster_node_role_path" {
  description = <<-EOT
    (Optional) The path to the Cluster Node IAM role.

    ex:
    ```
    anyscale_cluster_node_role_path = "/anyscale/"
    ```
  EOT
  type        = string
  default     = "/"
}

variable "anyscale_cluster_node_role_description" {
  description = <<-EOT
    (Optional) IAM Role description.

    If left `null`, will default to `Anyscale Cluster Node IAM Role`.

    ex:
    ```
    anyscale_cluster_node_role_description = "Anyscale Cluster Node IAM Role"
    ```
  EOT
  type        = string
  default     = null
}

# Cluster Node Custom Policy
variable "anyscale_cluster_node_custom_policy_name" {
  description = <<-EOT
    (Optional) Name for the Anyscale cluster node custom IAM policy.

    If left `null`, will default to `anyscale_cluster_node_custom_policy_prefix`.

    ex:
    ```
    anyscale_cluster_node_custom_policy_name = "anyscale-cluster-node-custom-policy"
    ```
  EOT

  type    = string
  default = null
}

variable "anyscale_cluster_node_custom_policy_prefix" {
  description = <<-EOT
    (Optional) Name prefix for the Anyscale cluster node custom IAM policy.

    If `anyscale_cluster_node_custom_policy_name` is provided, it will override this variable.

    ex:
    ```
    anyscale_cluster_node_custom_policy_prefix = "anyscale-cluster-node-custom-"
    ```
  EOT
  type        = string
  default     = "anyscale-cluster-node-custom-"
}

variable "anyscale_cluster_node_custom_policy_path" {
  description = <<-EOT
    (Optional) Path of the Anyscale cluster node custom IAM policy.

    ex:
    ```
    anyscale_cluster_node_custom_policy_path = "/"
    ```
  EOT
  type        = string
  default     = "/"
}

variable "anyscale_cluster_node_custom_policy_description" {
  description = <<-EOT
    (Optional) Anyscale IAM cluster node custom policy description.

    ex:
    ```
    anyscale_cluster_node_custom_policy_description = "Anyscale Cluster Node Custom Policy"
    ```
  EOT
  type        = string
  default     = "Anyscale Cluster Node IAM Policy"
}

variable "anyscale_cluster_node_custom_policy" {
  description = <<-EOT
    (Optional) Anyscale cluster node custom IAM policy.

    ex:
    ```
    anyscale_cluster_node_custom_policy = {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "ec2:DescribeInstances"
          ],
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
    (Optional) List of IAM custom or managed policy ARNs to attach to the role.

    ex:
    ```
    anyscale_cluster_node_managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"]
    ```
  EOT
  type        = list(string)
  default     = []
}

variable "anyscale_cluster_node_custom_assume_role_policy" {
  description = <<-EOT
    (Optional) Anyscale IAM cluster node role custom assume role policy.

    This overrides the default assume role policy. It must include the `sts:AssumeRole` action and at a minimum,
    needs to include the `ec2.amazonaws.com` service principal. Must be in JSON format.

    ex:
    ```
    anyscale_cluster_node_custom_assume_role_policy = {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "sts:AssumeRole"
          ],
          "Principal": {
            "Service": "ec2.amazonaws.com"
          }
        }
      ]
    }
    ```
  EOT
  type        = string
  default     = null
}

variable "create_cluster_node_cloudwatch_policy" {
  description = <<-EOT
    (Optional) Determines whether to create the CloudWatch IAM policy for the cluster node role.

    ex:
    ```
    create_cluster_node_cloudwatch_policy = true
    ```
  EOT
  type        = bool
  default     = false
}

variable "anyscale_cluster_node_cloudwatch_policy_name" {
  description = <<-EOT
    (Optional) Name for the Anyscale cluster node CloudWatch IAM policy.

    If left `null`, will default to `anyscale_cluster_node_cloudwatch_policy_prefix`.

    ex:
    ```
    anyscale_cluster_node_cloudwatch_policy_name = "anyscale-cluster-cloudwatch-policy"
    ```
  EOT
  type        = string
  default     = null
}

variable "anyscale_cluster_node_cloudwatch_policy_prefix" {
  description = <<-EOT
    (Optional) Name prefix for the Anyscale cluster node CloudWatch IAM policy.

    If `anyscale_cluster_node_cloudwatch_policy_name` is provided, it will override this variable.

    ex:
    ```
    anyscale_cluster_node_cloudwatch_policy_prefix = "anyscale-cluster-cloudwatch-"
    ```
  EOT
  type        = string
  default     = "anyscale-cluster-cloudwatch-"
}

variable "anyscale_cluster_node_cloudwatch_policy_path" {
  description = <<-EOT
    (Optional) Path of the Anyscale cluster node CloudWatch IAM policy.

    ex:
    ```
    anyscale_cluster_node_cloudwatch_policy_path = "/anyscale/"
    ```
  EOT
  type        = string
  default     = "/"
}
variable "anyscale_cluster_node_cloudwatch_policy_description" {
  description = <<-EOT
    (Optional) Anyscale IAM cluster node CloudWatch policy description.

    ex:
    ```
    anyscale_cluster_node_cloudwatch_policy_description = "Anyscale Cluster Node CloudWatch Policy"
    ```
  EOT
  type        = string
  default     = "Anyscale Cluster Node CloudWatch Policy"
}

# ------------------
# Cluster Node Secrets Policy
# ------------------
variable "anyscale_cluster_node_byod_secrets_policy_name" {
  description = <<-EOT
    (Optional) Name for the Anyscale cluster node Secrets IAM policy.

    If left `null`, will default to `anyscale_cluster_node_secrets_policy_prefix`.
    If provided, overrides the `anyscale_cluster_node_secrets_policy_prefix` variable.

    ex:
    ```
    anyscale_cluster_node_secrets_policy_name = "anyscale-cluster-node-secrets-policy"
    #checkov:skip=CKV_SECRET_6:Secrets Policy Name is not a secret'
    ```
  EOT
  type        = string
  default     = null
}
variable "anyscale_cluster_node_byod_secrets_policy_prefix" {
  description = <<-EOT
    (Optional) Name prefix for the Anyscale cluster node Secrets IAM policy.

    If `anyscale_cluster_node_secrets_policy_name` is provided, it will override this variable.
    Default is `null` but is set to `anyscale-cluster-node-secrets-` in a local variable.

    ex:
    ```
    anyscale_cluster_node_secrets_policy_prefix = "anyscale-cluster-node-secrets-"
    #checkov:skip=CKV_SECRET_6:Secrets Policy Prefix is not a secret'
    ```
  EOT
  type        = string
  default     = null
}

variable "anyscale_cluster_node_byod_secrets_policy_path" {
  description = <<-EOT
    (Optional) Path of the Anyscale cluster node SecretsManager IAM policy.

    ex:
    ```
    anyscale_cluster_node_secrets_policy_path = "/"
    ```
  EOT
  type        = string
  default     = "/"
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
    #checkov:skip=CKV_SECRET_6:Doc example
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

# ------------------
# S3 Bucket Access Related
variable "create_iam_s3_policy" {
  description = <<-EOT
    (Optional) Determines whether to create the S3 Access Policy for IAM roles.
    Requires anyscale_s3_bucket_arn (below).

    ex:
    ```
    create_iam_s3_policy = true
    ```
  EOT
  type        = bool
  default     = true
}
variable "anyscale_s3_bucket_arn" {
  description = <<-EOT
    (Optional) The S3 Bucket arn that the IAM Roles need access to.

    If not provided, we will not create an S3 Bucket Access Policy.

    ex:
    ```
    anyscale_s3_bucket_arn = "arn:aws:s3:::demo-bucket"
    ```
  EOT
  type        = string
  default     = ""
}

variable "anyscale_iam_s3_policy_name" {
  description = <<-EOT
    (Optional) Name for the Anyscale S3 access IAM policy.

    If left `null`, will default to `anyscale_iam_s3_policy_prefix`.
    If provided, overrides the `anyscale_iam_s3_policy_prefix` variable.

    ex:
    ```
    anyscale_iam_s3_policy_name = "anyscale-iam-s3-policy"
    ```
  EOT
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
