[![Build Status][badge-build]][build-status]
[![Terraform Version][badge-terraform]](https://github.com/hashicorp/terraform/releases)
[![AWS Provider Version][badge-tf-aws]](https://github.com/terraform-providers/terraform-provider-aws/releases)

# aws-anyscale-s3
This sub-module creates the default S3 resources needed for Anyscale to work in a customers environment. It should be used from the [root module](../../README.md).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0, < 7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.anyscale_managed_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_cors_configuration.anyscale_managed_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_cors_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.anyscale_managed_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.anyscale_managed_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_public_access_block.anyscale_managed_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.anyscale_managed_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.anyscale_managed_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_anyscale_bucket_name"></a> [anyscale\_bucket\_name](#input\_anyscale\_bucket\_name) | (Optional - forces new resource) The name of the bucket. Conflicts with anyscale\_bucket\_prefix. Default is `null`. | `string` | `null` | no |
| <a name="input_anyscale_bucket_prefix"></a> [anyscale\_bucket\_prefix](#input\_anyscale\_bucket\_prefix) | (Optional - forces new resource) Creates a unique bucket name beginning with the specified prefix. Conflicts with anyscale\_bucket\_name. Default is `anyscale-`. | `string` | `"anyscale-"` | no |
| <a name="input_anyscale_cloud_id"></a> [anyscale\_cloud\_id](#input\_anyscale\_cloud\_id) | (Optional) Anyscale Cloud ID. Default is `null`. | `string` | `null` | no |
| <a name="input_cors_rule"></a> [cors\_rule](#input\_cors\_rule) | (Optional)<br/>Object containing a rule of Cross-Origin Resource Sharing.<br/>The default allows GET, POST, PUT, HEAD, and DELETE<br/>access for the purpose of viewing logs and other functionality<br/>from within the Anyscale Web UI (*.anyscale.com).<br/><br/>ex:<pre>cors_rule = {<br/>  allowed_headers = ["*"]<br/>  allowed_methods = [GET", "POST", "PUT", "HEAD", "DELETE"]<br/>  allowed_origins = ["https://*.anyscale.com"]<br/>}</pre> | `any` | <pre>{<br/>  "allowed_headers": [<br/>    "*"<br/>  ],<br/>  "allowed_methods": [<br/>    "GET",<br/>    "POST",<br/>    "PUT",<br/>    "HEAD",<br/>    "DELETE"<br/>  ],<br/>  "allowed_origins": [<br/>    "https://*.anyscale.com"<br/>  ],<br/>  "expose_headers": []<br/>}</pre> | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | (Optional) Set to true to delete all objects from the bucket so that the bucket can be destroyed without error.<br/>These objects are not recoverable.<br/>Default is `false`. With this default, you need to empty the bucket if there are objects before `terraform destroy` can be completed. | `bool` | `false` | no |
| <a name="input_lifecycle_rule"></a> [lifecycle\_rule](#input\_lifecycle\_rule) | (Optional) List of maps containing configuration of object lifecycle management. Default is an empty list. | `any` | `[]` | no |
| <a name="input_logging"></a> [logging](#input\_logging) | (Optional) Map containing access bucket logging configuration. Default is an empty map. | `map(string)` | `{}` | no |
| <a name="input_module_enabled"></a> [module\_enabled](#input\_module\_enabled) | (Optional) Whether to create the resources inside this module. Default is `true`. | `bool` | `true` | no |
| <a name="input_object_versioning"></a> [object\_versioning](#input\_object\_versioning) | (Optional) Boolean specifying object versioning configuration. Default is `false`. | `bool` | `false` | no |
| <a name="input_server_side_encryption"></a> [server\_side\_encryption](#input\_server\_side\_encryption) | (Optional)<br/>Map containing server-side encryption configuration.<br/><br/>ex using KMS:<pre>server_side_encryption = {<br/>  kms_master_key_id = "key_id"<br/>  sse_algorithm     = "aws:kms"<br/>}</pre>ex using AES256 (default):<pre>server_side_encryption = {<br/>  sse_algorithm = "AES256"<br/>}</pre> | `map(string)` | <pre>{<br/>  "sse_algorithm": "AES256"<br/>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to all resources that accept tags. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | The ARN of the bucket. Will be of format arn:aws:s3:::bucketname. |
| <a name="output_s3_bucket_id"></a> [s3\_bucket\_id](#output\_s3\_bucket\_id) | The name of the bucket. |
| <a name="output_s3_bucket_region"></a> [s3\_bucket\_region](#output\_s3\_bucket\_region) | The AWS region this bucket resides in. |
<!-- END_TF_DOCS -->

<!-- References -->
[Terraform]: https://www.terraform.io
[Anyscale]: https://www.anyscale.com
[Issues]: https://github.com/anyscale/terraform-aws-anyscale-cloudfoundation-modules/issues
[badge-release]: https://img.shields.io/github/v/release/anyscale/terraform-aws-anyscale-cloudfoundation-modules.svg?style=for-the-badge&labelColor=0066FF&color=CCE0FF
[badge-build]: https://img.shields.io/github/actions/workflow/status/anyscale/terraform-aws-anyscale-cloudfoundation-modules/main.yml?style=for-the-badge
[badge-terraform]: https://img.shields.io/badge/terraform-1.9.x+%20-623CE4.svg?logo=terraform&style=for-the-badge&labelColor=DDDDDD
[badge-tf-aws]: https://img.shields.io/badge/AWS-5.+_or_6.+-F8991D.svg?logo=terraform&style=for-the-badge&labelColor=DDDDDD
[badge-anyscale-cli]: https://img.shields.io/badge/anyscale%20cli-0.26.40+-0066FF.svg?style=for-the-badge&labelColor=CCE0FF&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAzIiBoZWlnaHQ9IjIwMyIgdmlld0JveD0iMCAwIDIwMyAyMDMiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxwYXRoIGQ9Ik0xNDMuNzg5IDEwNC42NzVMMTE2LjMyMyAxNTIuMjUySDE3MS42MzVDMTczLjY2NiAxNTIuMjUyIDE3NS41NDUgMTUxLjE3IDE3Ni41NyAxNDkuNDA1TDIwMi4zOTUgMTA0LjY3NUgxNDMuNzg5WiIgZmlsbD0iIzAwNjZGRiIvPgo8cGF0aCBkPSJNMjAyLjM5NSA5OC4zMjUzTDE3Ni41NyA1My41OTQ5QzE3NS41NTUgNTEuODI5NiAxNzMuNjc2IDUwLjc0NzYgMTcxLjYzNSA1MC43NDc2SDExNi4zMjNMMTQzLjc4OSA5OC4zMjUzSDIwMi4zOTVaIiBmaWxsPSIjMDA2NkZGIi8+CjxwYXRoIGQ9Ik02MS4zODk0IDUwLjc0NzZIMTE2LjMyMkw4OC42NjYxIDIuODQ3MjZDODcuNjUwNiAxLjA4MTk2IDg1Ljc3MTQgMCA4My43MzA5IDBIMzIuMDgxNkw2MS4zNzk5IDUwLjc0NzZINjEuMzg5NFoiIGZpbGw9IiMwMDY2RkYiLz4KPHBhdGggZD0iTTI2LjU4NjQgMy4xNjk5NUwwLjc2MTc2NCA0Ny45MDA0Qy0wLjI1Mzc1OCA0OS42NjU3IC0wLjI1Mzc1OCA1MS44Mjk2IDAuNzYxNzY0IDUzLjU5NDlMMjguNDE4MSAxMDEuNDk1TDU1Ljg4NDcgNTMuOTE3NkwyNi41ODY0IDMuMTY5OTVaIiBmaWxsPSIjMDA2NkZGIi8+CjxwYXRoIGQ9Ik01NS44OTQyIDE0OS4wNzNMMjguNDI3NiAxMDEuNDk1TDAuNzYxNzY0IDE0OS40MDVDLTAuMjUzNzU4IDE1MS4xNyAtMC4yNTM3NTggMTUzLjMzNCAwLjc2MTc2NCAxNTUuMUwyNi41ODY0IDE5OS44M0w1NS44ODQ3IDE0OS4wODJMNTUuODk0MiAxNDkuMDczWiIgZmlsbD0iIzAwNjZGRiIvPgo8cGF0aCBkPSJNMzIuMDgxNiAyMDNIODMuNzMwOUM4NS43NjE5IDIwMyA4Ny42NDExIDIwMS45MTggODguNjY2MSAyMDAuMTUzTDExNi4zMjIgMTUyLjI1Mkg2MS4zODk0TDMyLjA5MTEgMjAzSDMyLjA4MTZaIiBmaWxsPSIjMDA2NkZGIi8+Cjwvc3ZnPg==
[build-status]: https://github.com/anyscale/terraform-aws-anyscale-cloudfoundation-modules/actions
