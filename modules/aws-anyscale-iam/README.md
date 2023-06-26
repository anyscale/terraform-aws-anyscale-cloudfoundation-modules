[![Build Status][badge-build]][build-status]
[![Terraform Version][badge-terraform]](https://github.com/hashicorp/terraform/releases)
[![AWS Provider Version][badge-tf-aws]](https://github.com/terraform-providers/terraform-provider-aws/releases)

# aws-anyscale-iam
This module creates the default IAM resources needed for Anyscale to work in a customers environment.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.anyscale_cluster_node_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.anyscale_cluster_node_custom_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.anyscale_iam_custom_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.anyscale_s3_access_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.anyscale_servicesv2_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.anyscale_steadystate_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.anyscale_access_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.anyscale_cluster_node_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.anyscale_access_role_s3_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.anyscale_cluster_node_container_registry_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.anyscale_cluster_node_custom_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.anyscale_cluster_node_managed_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.anyscale_cluster_node_s3_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.anyscale_iam_role_container_registry_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.anyscale_iam_role_custom_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.anyscale_iam_role_servicesv2_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.anyscale_iam_role_steady_state_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.managed_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.iam_anyscale_cluster_node_assumerole_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.iam_anyscale_crossacct_assumerole_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.iam_anyscale_s3_bucket_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.iam_anyscale_services_v2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.iam_anyscale_steadystate_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_anyscale_access_managed_policy_arns"></a> [anyscale\_access\_managed\_policy\_arns](#input\_anyscale\_access\_managed\_policy\_arns) | (Optional) List of IAM custom or managed policy ARNs to attach to the role. Default is an empty list. | `list(string)` | `[]` | no |
| <a name="input_anyscale_access_role_description"></a> [anyscale\_access\_role\_description](#input\_anyscale\_access\_role\_description) | (Optional) IAM Role description. Default is `null`. | `string` | `null` | no |
| <a name="input_anyscale_access_role_name"></a> [anyscale\_access\_role\_name](#input\_anyscale\_access\_role\_name) | (Optional, forces creation of new resource) The name of the Anyscale IAM access role. Conflicts with anyscale\_access\_role\_name\_prefix. Default is `null`. | `string` | `null` | no |
| <a name="input_anyscale_access_role_name_prefix"></a> [anyscale\_access\_role\_name\_prefix](#input\_anyscale\_access\_role\_name\_prefix) | (Optional, forces creation of new resource) The prefix of the Anyscale IAM access role. Conflicts with anyscale\_access\_role\_name. Default is `anyscale-iam-role-`. | `string` | `"anyscale-iam-role-"` | no |
| <a name="input_anyscale_access_role_path"></a> [anyscale\_access\_role\_path](#input\_anyscale\_access\_role\_path) | (Optional) The path to the IAM role. Default is `/` | `string` | `"/"` | no |
| <a name="input_anyscale_access_servicesv2_policy_description"></a> [anyscale\_access\_servicesv2\_policy\_description](#input\_anyscale\_access\_servicesv2\_policy\_description) | (Optional) Anyscale Services v2 policy description. Default is `Anyscale IAM policy for Services v2 - assigned to the Anyscale Access role.` | `string` | `"Anyscale IAM policy for Services v2 - assigned to the Anyscale Access role."` | no |
| <a name="input_anyscale_access_servicesv2_policy_name"></a> [anyscale\_access\_servicesv2\_policy\_name](#input\_anyscale\_access\_servicesv2\_policy\_name) | (Optional) Name for the Anyscale Services v2 Policy. Will use policy\_name\_prefix if this is set to `null`. Default is `null`. | `string` | `null` | no |
| <a name="input_anyscale_access_servicesv2_policy_path"></a> [anyscale\_access\_servicesv2\_policy\_path](#input\_anyscale\_access\_servicesv2\_policy\_path) | (Optional) Path for the Anyscale Services v2 IAM policy. Default is `/`. | `string` | `"/"` | no |
| <a name="input_anyscale_access_servicesv2_policy_prefix"></a> [anyscale\_access\_servicesv2\_policy\_prefix](#input\_anyscale\_access\_servicesv2\_policy\_prefix) | (Optional) Name prefix for the Anyscale default Services v2 policy. Conflicts with anyscale\_access\_servicesv2\_policy\_name. Default is `anyscale-servicesv2-`. | `string` | `"anyscale-servicesv2-"` | no |
| <a name="input_anyscale_access_steadystate_policy_description"></a> [anyscale\_access\_steadystate\_policy\_description](#input\_anyscale\_access\_steadystate\_policy\_description) | (Optional) Anyscale steady state IAM policy description. Default is `Anyscale Steady State IAM Policy` | `string` | `"Anyscale Steady State IAM Policy"` | no |
| <a name="input_anyscale_access_steadystate_policy_name"></a> [anyscale\_access\_steadystate\_policy\_name](#input\_anyscale\_access\_steadystate\_policy\_name) | (Optional) Name for the Anyscale default steady state IAM policy. Will use policy\_name\_prefix if this is set to `null`. Default is `null`. | `string` | `null` | no |
| <a name="input_anyscale_access_steadystate_policy_path"></a> [anyscale\_access\_steadystate\_policy\_path](#input\_anyscale\_access\_steadystate\_policy\_path) | (Optional) Path for the Anyscale default steady steate IAM policy. Defualt is `/`. | `string` | `"/"` | no |
| <a name="input_anyscale_access_steadystate_policy_prefix"></a> [anyscale\_access\_steadystate\_policy\_prefix](#input\_anyscale\_access\_steadystate\_policy\_prefix) | (Optional) Name prefix for the Anyscale default steady state IAM policy. Conflicts with anyscale\_access\_steadystate\_policy\_name. Default is `anyscale-steady_state-`. | `string` | `"anyscale-steady_state-"` | no |
| <a name="input_anyscale_cloud_id"></a> [anyscale\_cloud\_id](#input\_anyscale\_cloud\_id) | (Required) Anyscale Cloud ID | `string` | `null` | no |
| <a name="input_anyscale_cluster_node_custom_policy"></a> [anyscale\_cluster\_node\_custom\_policy](#input\_anyscale\_cluster\_node\_custom\_policy) | (Optional) Anyscale cluster node custom IAM policy. Default is `null`. | `string` | `null` | no |
| <a name="input_anyscale_cluster_node_custom_policy_description"></a> [anyscale\_cluster\_node\_custom\_policy\_description](#input\_anyscale\_cluster\_node\_custom\_policy\_description) | (Optional) Anyscale IAM cluster node custom policy description. Default is `Anyscale Cluster Node IAM Policy`. | `string` | `"Anyscale Cluster Node IAM Policy"` | no |
| <a name="input_anyscale_cluster_node_custom_policy_name"></a> [anyscale\_cluster\_node\_custom\_policy\_name](#input\_anyscale\_cluster\_node\_custom\_policy\_name) | (Optional) Name for the Anyscale cluster node custom IAM policy. Default is `null`. | `string` | `null` | no |
| <a name="input_anyscale_cluster_node_custom_policy_path"></a> [anyscale\_cluster\_node\_custom\_policy\_path](#input\_anyscale\_cluster\_node\_custom\_policy\_path) | (Optional) Path of the Anyscale cluster node custom IAM policy. Default is `/`. | `string` | `"/"` | no |
| <a name="input_anyscale_cluster_node_custom_policy_prefix"></a> [anyscale\_cluster\_node\_custom\_policy\_prefix](#input\_anyscale\_cluster\_node\_custom\_policy\_prefix) | (Optional) Name prefix for the Anyscale cluster node custom IAM policy. Default is `anyscale-iam-role-custom-`. | `string` | `"anyscale-cluster-node-custom-"` | no |
| <a name="input_anyscale_cluster_node_managed_policy_arns"></a> [anyscale\_cluster\_node\_managed\_policy\_arns](#input\_anyscale\_cluster\_node\_managed\_policy\_arns) | (Optional) List of IAM custom or managed policy ARNs to attach to the role. Default is an empty list. | `list(string)` | `[]` | no |
| <a name="input_anyscale_cluster_node_role_description"></a> [anyscale\_cluster\_node\_role\_description](#input\_anyscale\_cluster\_node\_role\_description) | (Optional) IAM Role description. Default is `null`. | `string` | `null` | no |
| <a name="input_anyscale_cluster_node_role_name"></a> [anyscale\_cluster\_node\_role\_name](#input\_anyscale\_cluster\_node\_role\_name) | (Optional, forces creation of new resource) The name of the Anyscale IAM cluster node role. Default is `null`. | `string` | `null` | no |
| <a name="input_anyscale_cluster_node_role_name_prefix"></a> [anyscale\_cluster\_node\_role\_name\_prefix](#input\_anyscale\_cluster\_node\_role\_name\_prefix) | (Optional, forces creation of new resource) The prefix of the Anyscale Cluster Node IAM role. Default is `anyscale-cluster-node-`. | `string` | `"anyscale-cluster-node-"` | no |
| <a name="input_anyscale_cluster_node_role_path"></a> [anyscale\_cluster\_node\_role\_path](#input\_anyscale\_cluster\_node\_role\_path) | (Optional) The path to the Cluster Node IAM role. Default is `/`. | `string` | `"/"` | no |
| <a name="input_anyscale_custom_policy"></a> [anyscale\_custom\_policy](#input\_anyscale\_custom\_policy) | (Optional) Anyscale custom IAM policy. Default is `null`. | `string` | `null` | no |
| <a name="input_anyscale_custom_policy_description"></a> [anyscale\_custom\_policy\_description](#input\_anyscale\_custom\_policy\_description) | (Optional) Anyscale IAM custom policy description. Default is `Anyscale IAM Policy`. | `string` | `"Anyscale IAM Policy"` | no |
| <a name="input_anyscale_custom_policy_name"></a> [anyscale\_custom\_policy\_name](#input\_anyscale\_custom\_policy\_name) | (Optional) Name for an Anyscale custom IAM policy. Default is `null`. | `string` | `null` | no |
| <a name="input_anyscale_custom_policy_name_prefix"></a> [anyscale\_custom\_policy\_name\_prefix](#input\_anyscale\_custom\_policy\_name\_prefix) | (Optional) Name prefix for the Anyscale custom IAM policy. Default is `anyscale-iam-role-custom-`. | `string` | `"anyscale-iam-role-custom-"` | no |
| <a name="input_anyscale_custom_policy_path"></a> [anyscale\_custom\_policy\_path](#input\_anyscale\_custom\_policy\_path) | (Optional) Path of the Anyscale custom IAM policy. Default is `/`. | `string` | `"/"` | no |
| <a name="input_anyscale_default_trusted_role_arns"></a> [anyscale\_default\_trusted\_role\_arns](#input\_anyscale\_default\_trusted\_role\_arns) | (Optional) ARNs of AWS entities who can assume these roles. If `anyscale_trusted_role_arns` is provided, it will override this variable. Default is the AWS account for Anyscale Production. | `list(string)` | <pre>[<br>  "arn:aws:iam::525325868955:root"<br>]</pre> | no |
| <a name="input_anyscale_iam_s3_policy_description"></a> [anyscale\_iam\_s3\_policy\_description](#input\_anyscale\_iam\_s3\_policy\_description) | (Optional) Anyscale S3 access IAM policy description. Default is `Anyscale S3 Access IAM Policy`. | `string` | `"Anyscale S3 Access IAM Policy"` | no |
| <a name="input_anyscale_iam_s3_policy_name"></a> [anyscale\_iam\_s3\_policy\_name](#input\_anyscale\_iam\_s3\_policy\_name) | (Optional) Name for the Anyscale S3 access IAM policy. Default is `null`. | `string` | `null` | no |
| <a name="input_anyscale_iam_s3_policy_name_prefix"></a> [anyscale\_iam\_s3\_policy\_name\_prefix](#input\_anyscale\_iam\_s3\_policy\_name\_prefix) | (Optional) Name prefix for the Anyscale S3 access IAM policy. Default is `anyscale-iam-s3-`. | `string` | `"anyscale-iam-s3-"` | no |
| <a name="input_anyscale_iam_s3_policy_path"></a> [anyscale\_iam\_s3\_policy\_path](#input\_anyscale\_iam\_s3\_policy\_path) | (Optional) Path of the Anyscale S3 access IAM policy. Default is `/`. | `string` | `"/"` | no |
| <a name="input_anyscale_s3_bucket_arn"></a> [anyscale\_s3\_bucket\_arn](#input\_anyscale\_s3\_bucket\_arn) | (Optional) The S3 Bucket arn that the IAM Roles need access to.<br>If not provided, make sure to set `create_iam_s3_policy` to `false` otherwise this will throw an error.<br>Default is `null`. | `string` | `null` | no |
| <a name="input_anyscale_trusted_role_arns"></a> [anyscale\_trusted\_role\_arns](#input\_anyscale\_trusted\_role\_arns) | (Optional) ARNs of AWS entities who can assume these roles. If this variable is provided, it will override `anyscale_default_trusted_role_arns`. Default is an empty list. | `list(string)` | `[]` | no |
| <a name="input_anyscale_trusted_role_sts_externalid"></a> [anyscale\_trusted\_role\_sts\_externalid](#input\_anyscale\_trusted\_role\_sts\_externalid) | (Optional) STS ExternalId condition values to use with a role. Default is an empty list. | `any` | `[]` | no |
| <a name="input_create_anyscale_access_role"></a> [create\_anyscale\_access\_role](#input\_create\_anyscale\_access\_role) | (Optional) Determines whether to create the Anyscale access role. Default is `true`. | `bool` | `true` | no |
| <a name="input_create_anyscale_access_servicesv2_policy"></a> [create\_anyscale\_access\_servicesv2\_policy](#input\_create\_anyscale\_access\_servicesv2\_policy) | (Optional) Determines if the IAM policy for Services v2 is created. Default is `true`. | `bool` | `true` | no |
| <a name="input_create_anyscale_access_steadystate_policy"></a> [create\_anyscale\_access\_steadystate\_policy](#input\_create\_anyscale\_access\_steadystate\_policy) | (Optional) Deterimines if the Anyscale IAM steadystate policy is created. Default is `true`. | `bool` | `true` | no |
| <a name="input_create_cluster_node_instance_profile"></a> [create\_cluster\_node\_instance\_profile](#input\_create\_cluster\_node\_instance\_profile) | (Optional) Determines whether to create an instance profile role. Default is `true`. | `bool` | `true` | no |
| <a name="input_create_iam_s3_policy"></a> [create\_iam\_s3\_policy](#input\_create\_iam\_s3\_policy) | (Optional) Determines whether to create the S3 Access Policy for IAM roles. Requires anyscale\_s3\_bucket\_arn (below). Default is `true`. | `bool` | `true` | no |
| <a name="input_enable_ec2_container_registry_readonly_access"></a> [enable\_ec2\_container\_registry\_readonly\_access](#input\_enable\_ec2\_container\_registry\_readonly\_access) | (Optional) Determines if the Amazon EC2 container registry read-only access policy is attached. If false, an alternative must be specified in anyscale\_custom\_policy. Default is `true`. | `string` | `true` | no |
| <a name="input_module_enabled"></a> [module\_enabled](#input\_module\_enabled) | (Optional) Determines whether to create the resources inside this module. Default is `true`. | `bool` | `true` | no |
| <a name="input_role_permissions_boundary_arn"></a> [role\_permissions\_boundary\_arn](#input\_role\_permissions\_boundary\_arn) | (Optional) Permissions boundary ARN to use for IAM role. Default is `null`. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to all resources that accept tags. Default is an empty map. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_anyscale_cluster_node_custom_policy_arn"></a> [anyscale\_cluster\_node\_custom\_policy\_arn](#output\_anyscale\_cluster\_node\_custom\_policy\_arn) | ARN of Anyscale cluster node custom policy |
| <a name="output_anyscale_cluster_node_custom_policy_id"></a> [anyscale\_cluster\_node\_custom\_policy\_id](#output\_anyscale\_cluster\_node\_custom\_policy\_id) | Policy ID of Anyscale cluster node custom policy |
| <a name="output_anyscale_cluster_node_custom_policy_name"></a> [anyscale\_cluster\_node\_custom\_policy\_name](#output\_anyscale\_cluster\_node\_custom\_policy\_name) | Name of Anyscale cluster node custom policy |
| <a name="output_anyscale_cluster_node_custom_policy_path"></a> [anyscale\_cluster\_node\_custom\_policy\_path](#output\_anyscale\_cluster\_node\_custom\_policy\_path) | Path of Anyscale cluster node custom policy |
| <a name="output_anyscale_iam_custom_policy_arn"></a> [anyscale\_iam\_custom\_policy\_arn](#output\_anyscale\_iam\_custom\_policy\_arn) | ARN of Anyscale custom IAM policy |
| <a name="output_anyscale_iam_custom_policy_id"></a> [anyscale\_iam\_custom\_policy\_id](#output\_anyscale\_iam\_custom\_policy\_id) | Policy ID of Anyscale custom IAM policy |
| <a name="output_anyscale_iam_custom_policy_name"></a> [anyscale\_iam\_custom\_policy\_name](#output\_anyscale\_iam\_custom\_policy\_name) | Name of Anyscale custom IAM policy |
| <a name="output_anyscale_iam_custom_policy_path"></a> [anyscale\_iam\_custom\_policy\_path](#output\_anyscale\_iam\_custom\_policy\_path) | Path of Anyscale custom IAM policy |
| <a name="output_anyscale_iam_s3_policy_arn"></a> [anyscale\_iam\_s3\_policy\_arn](#output\_anyscale\_iam\_s3\_policy\_arn) | ARN of Anyscale IAM S3 policy |
| <a name="output_anyscale_iam_s3_policy_id"></a> [anyscale\_iam\_s3\_policy\_id](#output\_anyscale\_iam\_s3\_policy\_id) | Policy ID of Anyscale IAM S3 policy |
| <a name="output_anyscale_iam_s3_policy_name"></a> [anyscale\_iam\_s3\_policy\_name](#output\_anyscale\_iam\_s3\_policy\_name) | Name of Anyscale IAM S3 policy |
| <a name="output_anyscale_iam_s3_policy_path"></a> [anyscale\_iam\_s3\_policy\_path](#output\_anyscale\_iam\_s3\_policy\_path) | Path of Anyscale IAM S3 policy |
| <a name="output_anyscale_servicesv2_policy_arn"></a> [anyscale\_servicesv2\_policy\_arn](#output\_anyscale\_servicesv2\_policy\_arn) | ARN of Anyscale Steady State IAM policy |
| <a name="output_anyscale_servicesv2_policy_id"></a> [anyscale\_servicesv2\_policy\_id](#output\_anyscale\_servicesv2\_policy\_id) | Policy ID of Anyscale Steady State IAM policy |
| <a name="output_anyscale_servicesv2_policy_name"></a> [anyscale\_servicesv2\_policy\_name](#output\_anyscale\_servicesv2\_policy\_name) | Name of Anyscale Steady State IAM policy |
| <a name="output_anyscale_servicesv2_policy_path"></a> [anyscale\_servicesv2\_policy\_path](#output\_anyscale\_servicesv2\_policy\_path) | Path of Anyscale Steady State IAM policy |
| <a name="output_anyscale_steadystate_policy_arn"></a> [anyscale\_steadystate\_policy\_arn](#output\_anyscale\_steadystate\_policy\_arn) | ARN of Anyscale Steady State IAM policy |
| <a name="output_anyscale_steadystate_policy_id"></a> [anyscale\_steadystate\_policy\_id](#output\_anyscale\_steadystate\_policy\_id) | Policy ID of Anyscale Steady State IAM policy |
| <a name="output_anyscale_steadystate_policy_name"></a> [anyscale\_steadystate\_policy\_name](#output\_anyscale\_steadystate\_policy\_name) | Name of Anyscale Steady State IAM policy |
| <a name="output_anyscale_steadystate_policy_path"></a> [anyscale\_steadystate\_policy\_path](#output\_anyscale\_steadystate\_policy\_path) | Path of Anyscale Steady State IAM policy |
| <a name="output_iam_anyscale_access_role_arn"></a> [iam\_anyscale\_access\_role\_arn](#output\_iam\_anyscale\_access\_role\_arn) | ARN of Anyscale access IAM role |
| <a name="output_iam_anyscale_access_role_name"></a> [iam\_anyscale\_access\_role\_name](#output\_iam\_anyscale\_access\_role\_name) | Name of Anyscale access IAM role |
| <a name="output_iam_anyscale_access_role_path"></a> [iam\_anyscale\_access\_role\_path](#output\_iam\_anyscale\_access\_role\_path) | Path of Anyscale access IAM role |
| <a name="output_iam_anyscale_access_role_unique_id"></a> [iam\_anyscale\_access\_role\_unique\_id](#output\_iam\_anyscale\_access\_role\_unique\_id) | Unique ID of Anyscale access IAM role |
| <a name="output_iam_cluster_node_instance_profile_id"></a> [iam\_cluster\_node\_instance\_profile\_id](#output\_iam\_cluster\_node\_instance\_profile\_id) | IAM Instance profile's ID. |
| <a name="output_iam_cluster_node_instance_profile_name"></a> [iam\_cluster\_node\_instance\_profile\_name](#output\_iam\_cluster\_node\_instance\_profile\_name) | Name of IAM instance profile |
| <a name="output_iam_cluster_node_instance_profile_path"></a> [iam\_cluster\_node\_instance\_profile\_path](#output\_iam\_cluster\_node\_instance\_profile\_path) | Path of IAM instance profile |
| <a name="output_iam_cluster_node_instance_profile_role_arn"></a> [iam\_cluster\_node\_instance\_profile\_role\_arn](#output\_iam\_cluster\_node\_instance\_profile\_role\_arn) | ARN of IAM instance profile |
| <a name="output_iam_cluster_node_role_arn"></a> [iam\_cluster\_node\_role\_arn](#output\_iam\_cluster\_node\_role\_arn) | ARN OF IAM Role for Anyscale Instance Profile |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- References -->
[Terraform]: https://www.terraform.io
[Issues]: https://github.com/anyscale/sa-sandbox-terraform/issues
[badge-build]: https://github.com/anyscale/sa-sandbox-terraform/workflows/CI/CD%20Pipeline/badge.svg
[badge-terraform]: https://img.shields.io/badge/terraform-1.x%20-623CE4.svg?logo=terraform
[badge-tf-aws]: https://img.shields.io/badge/AWS-4.+-F8991D.svg?logo=terraform
[build-status]: https://github.com/anyscale/sa-sandbox-terraform/actions
