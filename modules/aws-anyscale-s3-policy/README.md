[![Build Status][badge-build]][build-status]
[![Terraform Version][badge-terraform]](https://github.com/hashicorp/terraform/releases)
[![AWS Provider Version][badge-tf-aws]](https://github.com/terraform-providers/terraform-provider-aws/releases)

# aws-anyscale-vpc
This module creates the default S3 resources needed for Anyscale to work in a customers environment.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.49.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket_policy.anyscale_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_iam_policy_document.anyscale_managed_s3_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_anyscale_bucket_name"></a> [anyscale\_bucket\_name](#input\_anyscale\_bucket\_name) | (Required) The S3 bucket name to apply the policy to. | `string` | n/a | yes |
| <a name="input_anyscale_cloud_id"></a> [anyscale\_cloud\_id](#input\_anyscale\_cloud\_id) | (Optional) Anyscale Cloud ID. Default is `null`. | `string` | `null` | no |
| <a name="input_anyscale_iam_access_role_arn"></a> [anyscale\_iam\_access\_role\_arn](#input\_anyscale\_iam\_access\_role\_arn) | (Required) The Anyscale IAM SteadyState role arn. | `string` | n/a | yes |
| <a name="input_anyscale_iam_cluster_node_role_arn"></a> [anyscale\_iam\_cluster\_node\_role\_arn](#input\_anyscale\_iam\_cluster\_node\_role\_arn) | (Required) The Anyscale IAM cluster node role arn. | `string` | n/a | yes |
| <a name="input_custom_s3_policy"></a> [custom\_s3\_policy](#input\_custom\_s3\_policy) | (Optional) A valid bucket policy in JSON. Default is `null`. | `string` | `null` | no |
| <a name="input_module_enabled"></a> [module\_enabled](#input\_module\_enabled) | (Optional) Whether to create the resources inside this module. Default is `true`. | `bool` | `true` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- References -->
[Terraform]: https://www.terraform.io
[Issues]: https://github.com/anyscale/sa-sandbox-terraform/issues
[badge-build]: https://github.com/anyscale/sa-sandbox-terraform/workflows/CI/CD%20Pipeline/badge.svg
[badge-terraform]: https://img.shields.io/badge/terraform-1.x%20-623CE4.svg?logo=terraform
[badge-tf-aws]: https://img.shields.io/badge/AWS-4.+-F8991D.svg?logo=terraform
[build-status]: https://github.com/anyscale/sa-sandbox-terraform/actions
