[![Build Status][badge-build]][build-status]
[![Terraform Version][badge-terraform]](https://github.com/hashicorp/terraform/releases)
[![AWS Provider Version][badge-tf-aws]](https://github.com/terraform-providers/terraform-provider-aws/releases)

# Examples for using the aws-anyscale-s3-policy module

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.62.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_anyscale_s3_bucket_policy"></a> [anyscale\_s3\_bucket\_policy](#module\_anyscale\_s3\_bucket\_policy) | ../ | n/a |
| <a name="module_anyscale_s3_bucket_policy_complete"></a> [anyscale\_s3\_bucket\_policy\_complete](#module\_anyscale\_s3\_bucket\_policy\_complete) | ../ | n/a |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../../aws-anyscale-iam | n/a |
| <a name="module_s3_bucket_custom_policy"></a> [s3\_bucket\_custom\_policy](#module\_s3\_bucket\_custom\_policy) | ../../aws-anyscale-s3 | n/a |
| <a name="module_s3_bucket_defaults"></a> [s3\_bucket\_defaults](#module\_s3\_bucket\_defaults) | ../../aws-anyscale-s3 | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy_document.custom_s3_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_anyscale_cloud_id"></a> [anyscale\_cloud\_id](#input\_anyscale\_cloud\_id) | (Optional) Anyscale Cloud ID | `string` | `null` | no |
| <a name="input_anyscale_deploy_env"></a> [anyscale\_deploy\_env](#input\_anyscale\_deploy\_env) | (Required) Anyscale deploy environment. Used in resource names and tags. | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region in which all resources will be created. | `string` | `"us-east-2"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to all resources that accept tags. | `map(string)` | <pre>{<br>  "environment": "test",<br>  "test": true<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_s3_bucket_custom_policy_id"></a> [s3\_bucket\_custom\_policy\_id](#output\_s3\_bucket\_custom\_policy\_id) | The ID of the anyscasle resource. |
| <a name="output_s3_bucket_id_defaults"></a> [s3\_bucket\_id\_defaults](#output\_s3\_bucket\_id\_defaults) | The ID of the anyscale resource. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- References -->
[Terraform]: https://www.terraform.io
[Issues]: https://github.com/anyscale/sa-sandbox-terraform/issues
[badge-build]: https://github.com/anyscale/sa-sandbox-terraform/workflows/CI/CD%20Pipeline/badge.svg
[badge-terraform]: https://img.shields.io/badge/terraform-1.x%20-623CE4.svg?logo=terraform
[badge-tf-aws]: https://img.shields.io/badge/AWS-4.+-F8991D.svg?logo=terraform
[build-status]: https://github.com/anyscale/sa-sandbox-terraform/actions
