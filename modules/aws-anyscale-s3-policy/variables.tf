# ------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables must be set when using this module.
# ------------------------------------------------------------------------------
variable "anyscale_bucket_name" {
  description = <<-EOT
    (Required) The S3 bucket name to apply the policy to.

    ex:
    ```
    anyscale_bucket_name = "my-anyscale-bucket"
    ```
  EOT
  type        = string
}

variable "anyscale_controlplane_role_arn" {
  description = <<-EOT
    (Required) The Anyscale IAM SteadyState role arn.

    ex:
    ```
    anyscale_controlplane_role_arn = "arn:aws:iam::123456789012:role/AnyscaleSteadyStateRole"
    ```
  EOT
  type        = string
}

variable "anyscale_dataplane_role_arn" {
  description = <<-EOT
    (Required) The Anyscale IAM cluster node role arn.

    ex:
    ```
    anyscale_dataplane_role_arn = "arn:aws:iam::123456789012:role/AnyscaleClusterNodeRole"
    ```
  EOT
  type        = string
}

# ------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These variables have defaults, but may be overridden.
# ------------------------------------------------------------------------------
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

variable "custom_s3_policy" {
  description = <<-EOT
    (Optional) JSON Encoded policy statements to merge with the default S3 bucket policy

    ex:
    ```
    custom_s3_policy = jsonencode({
      "Statement": [
        {
          "Effect": "Allow",
          "Action": "s3:GetObject",
          "Resource": "arn:aws:s3:::my-anyscale-bucket/*",
          "Principal": {
            "AWS": "arn:aws:iam::123456789012:role/OtherIAMRole"
          }
        }
      ]
    })
    ```
  EOT

  type    = any
  default = null
}
