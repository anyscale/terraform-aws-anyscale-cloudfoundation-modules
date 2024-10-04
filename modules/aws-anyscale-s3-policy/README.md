[![Build Status][badge-build]][build-status]
[![Terraform Version][badge-terraform]](https://github.com/hashicorp/terraform/releases)
[![AWS Provider Version][badge-tf-aws]](https://github.com/terraform-providers/terraform-provider-aws/releases)

# aws-anyscale-vpc
This sub-module creates the default S3 resources needed for Anyscale to work in a customers environment. It should be used from the [root module](../../README.md).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.41.0 |

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
| <a name="input_anyscale_bucket_name"></a> [anyscale\_bucket\_name](#input\_anyscale\_bucket\_name) | (Required) The S3 bucket name to apply the policy to.<br/><br/>ex:<pre>anyscale_bucket_name = "my-anyscale-bucket"</pre> | `string` | n/a | yes |
| <a name="input_anyscale_controlplane_role_arn"></a> [anyscale\_controlplane\_role\_arn](#input\_anyscale\_controlplane\_role\_arn) | (Required) The Anyscale IAM SteadyState role arn.<br/><br/>ex:<pre>anyscale_controlplane_role_arn = "arn:aws:iam::123456789012:role/AnyscaleSteadyStateRole"</pre> | `string` | n/a | yes |
| <a name="input_anyscale_dataplane_role_arn"></a> [anyscale\_dataplane\_role\_arn](#input\_anyscale\_dataplane\_role\_arn) | (Required) The Anyscale IAM cluster node role arn.<br/><br/>ex:<pre>anyscale_dataplane_role_arn = "arn:aws:iam::123456789012:role/AnyscaleClusterNodeRole"</pre> | `string` | n/a | yes |
| <a name="input_custom_s3_policy"></a> [custom\_s3\_policy](#input\_custom\_s3\_policy) | (Optional) JSON Encoded policy statements to merge with the default S3 bucket policy<br/><br/>ex:<pre>custom_s3_policy = jsonencode({<br/>  "Statement": [<br/>    {<br/>      "Effect": "Allow",<br/>      "Action": "s3:GetObject",<br/>      "Resource": "arn:aws:s3:::my-anyscale-bucket/*",<br/>      "Principal": {<br/>        "AWS": "arn:aws:iam::123456789012:role/OtherIAMRole"<br/>      }<br/>    }<br/>  ]<br/>})</pre> | `any` | `null` | no |
| <a name="input_module_enabled"></a> [module\_enabled](#input\_module\_enabled) | (Optional) Whether to create the resources inside this module.<br/><br/>ex:<pre>module_enabled = true</pre> | `bool` | `true` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

<!-- References -->
[Terraform]: https://www.terraform.io
[Issues]: https://github.com/anyscale/sa-sandbox-terraform/issues
[badge-build]: https://github.com/anyscale/sa-sandbox-terraform/workflows/CI/CD%20Pipeline/badge.svg
[badge-terraform]: https://img.shields.io/badge/terraform-1.x%20-623CE4.svg?logo=terraform
[badge-tf-aws]: https://img.shields.io/badge/AWS-5.+-F8991D.svg?logo=terraform
[build-status]: https://github.com/anyscale/sa-sandbox-terraform/actions
