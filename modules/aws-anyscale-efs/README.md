[![Build Status][badge-build]][build-status]
[![Terraform Version][badge-terraform]](https://github.com/hashicorp/terraform/releases)
[![AWS Provider Version][badge-tf-aws]](https://github.com/terraform-providers/terraform-provider-aws/releases)

# aws-anyscale-efs

This module creates an Elastic File System for Anyscale applications and workloads.

EFS is a cloud based, scalable file system for applications and workloads that can be in combination with other AWS cloud services. It offers shared storage, is designed for scalable performance and is secure & compliant with common regulatory standards.

EFS is required for you to use Anyscale Workspaces.

## Known Issues

EFS Policies to enforce TLS traffic are not currently supported. This requires additional changes to the way Workspaces mount EFS. NFS does not support TLS out of the box, however Amazon has an efs-mount-helper that does support TLS as well as additional IAM authentication options. For now, the variable: `attach_policy` has been changed to `false` which will by default not create the EFS policy. This is the only supported method for Anyscale Workspace clusters at this time.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_efs_access_point.anyscale_efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_access_point) | resource |
| [aws_efs_backup_policy.anyscale_efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_backup_policy) | resource |
| [aws_efs_file_system.anyscale_efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) | resource |
| [aws_efs_file_system_policy.anyscale_efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system_policy) | resource |
| [aws_efs_mount_target.anyscale_efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource |
| [aws_efs_replication_configuration.anyscale_efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_replication_configuration) | resource |
| [aws_iam_policy_document.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_points"></a> [access\_points](#input\_access\_points) | (Optional) A map of access point definitions to create. Default is none. | `any` | `{}` | no |
| <a name="input_anyscale_cloud_id"></a> [anyscale\_cloud\_id](#input\_anyscale\_cloud\_id) | (Optional) Anyscale Cloud ID. Default is `null`. | `string` | `null` | no |
| <a name="input_anyscale_efs_name"></a> [anyscale\_efs\_name](#input\_anyscale\_efs\_name) | (Optional) Elastic file system name. Will default to `efs_anyscale` if this var `null` and anyscale\_cloud\_id is also `null`. Default is `null`. | `string` | `null` | no |
| <a name="input_associated_security_group_ids"></a> [associated\_security\_group\_ids](#input\_associated\_security\_group\_ids) | (Optional) A list of security group IDs to add to the mount targets. Default is an empty list. | `list(string)` | `[]` | no |
| <a name="input_attach_policy"></a> [attach\_policy](#input\_attach\_policy) | (Optional) Determines whether a policy is attached to the file system. Default is `true`. | `bool` | `false` | no |
| <a name="input_availability_zone_name"></a> [availability\_zone\_name](#input\_availability\_zone\_name) | (Optional) The AWS Availability Zone in which to create the file system. Used to create a file system that uses One Zone storage classes. Default is `null`. | `string` | `null` | no |
| <a name="input_bypass_policy_lockout_safety_check"></a> [bypass\_policy\_lockout\_safety\_check](#input\_bypass\_policy\_lockout\_safety\_check) | (Optional) A flag to indicate whether to bypass the `aws_efs_file_system_policy` lockout safety check. Default is `false` | `bool` | `false` | no |
| <a name="input_create_backup_policy"></a> [create\_backup\_policy](#input\_create\_backup\_policy) | (Optional) Determines whether a backup policy is created. Default is `true`. | `bool` | `true` | no |
| <a name="input_create_replication_configuration"></a> [create\_replication\_configuration](#input\_create\_replication\_configuration) | (Optional) Determines whether a replication configuration is created. Default is `false`. | `bool` | `false` | no |
| <a name="input_efs_creation_token"></a> [efs\_creation\_token](#input\_efs\_creation\_token) | (Optional) A unique token used as reference when creating the Elastic File System to ensure idempotent file system creation. Default is `null` which forces Terraform to generate it. | `string` | `null` | no |
| <a name="input_efs_encrypted"></a> [efs\_encrypted](#input\_efs\_encrypted) | (Optional)<br/>Deterimnes if the Elastic File System disk will be encrypted.<br/><br/>ex:<pre>efs_encrypted = true</pre> | `bool` | `true` | no |
| <a name="input_efs_performance_mode"></a> [efs\_performance\_mode](#input\_efs\_performance\_mode) | (Optional) The file system performance mode. Can be either `generalPurpose` or `maxIO`. Default is `generalPurpose` | `string` | `"generalPurpose"` | no |
| <a name="input_efs_throughput_mode"></a> [efs\_throughput\_mode](#input\_efs\_throughput\_mode) | (Optional) Throughput mode for the file system. Defaults to `bursting`. Valid values: `bursting`, `provisioned`. When using `provisioned`, also set `provisioned_throughput_in_mibps`. Default is `bursting`. | `string` | `"bursting"` | no |
| <a name="input_enable_backup_policy"></a> [enable\_backup\_policy](#input\_enable\_backup\_policy) | (Optional) Determines whether a backup policy is `ENABLED` or `DISABLED`. Default is `true`. | `bool` | `true` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | (Optional)<br/>The ARN for the KMS encryption key to be used for encrypting EFS.<br/>When specifying `kms_key_arn`, efs\_encrypted needs to be set to `true`.<br/><br/>ex:<pre>kms_key_arn = "arn:aws:kms:us-west-2:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab"</pre> | `string` | `null` | no |
| <a name="input_lifecycle_policy_transition_to_ia"></a> [lifecycle\_policy\_transition\_to\_ia](#input\_lifecycle\_policy\_transition\_to\_ia) | (Optional) Indicates how long it takes to transition files to Infrequent Access storage class. No value, or an empty list, means never. Default is to transition to IA after 60 days. | `list(string)` | <pre>[<br/>  "AFTER_60_DAYS"<br/>]</pre> | no |
| <a name="input_lifecycle_policy_transition_to_primary_storage_class"></a> [lifecycle\_policy\_transition\_to\_primary\_storage\_class](#input\_lifecycle\_policy\_transition\_to\_primary\_storage\_class) | (Optional) Indicates the policy used to transition a file from Infrequent Access (IA) storage to primary storage. Default is `AFTER_1_ACCESS`. | `list(string)` | <pre>[<br/>  "AFTER_1_ACCESS"<br/>]</pre> | no |
| <a name="input_module_enabled"></a> [module\_enabled](#input\_module\_enabled) | (Optional) Whether to create the resources inside this module. Default is `true`. | `bool` | `true` | no |
| <a name="input_mount_target_ips"></a> [mount\_target\_ips](#input\_mount\_target\_ips) | (Optional) List of Target IPs. These should map to the list of mount target subnets. Default is an empty list. | `list(string)` | `[]` | no |
| <a name="input_mount_targets_subnet_count"></a> [mount\_targets\_subnet\_count](#input\_mount\_targets\_subnet\_count) | (Optional) The mount targets subnet count. This is included as the number of subnets is not always known at the creation time. Default is `0`. | `number` | `0` | no |
| <a name="input_mount_targets_subnets"></a> [mount\_targets\_subnets](#input\_mount\_targets\_subnets) | (Optional) List of mount target subnets. Default is an empty list. | `list(string)` | `[]` | no |
| <a name="input_override_policy_documents"></a> [override\_policy\_documents](#input\_override\_policy\_documents) | (Optional) List of IAM policy documents that are merged together into the exported document. In merging, statements with non-blank `sid`s will override statements with the same `sid`. Default is an empty list. | `list(string)` | `[]` | no |
| <a name="input_policy_statements"></a> [policy\_statements](#input\_policy\_statements) | (Optional) A list of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom permission usage. Default is an empty list. | `any` | `[]` | no |
| <a name="input_provisioned_throughput_in_mibps"></a> [provisioned\_throughput\_in\_mibps](#input\_provisioned\_throughput\_in\_mibps) | (Optional) The throughput, measured in MiB/s, that you want to provision for the file system. Only applicable with `throughput_mode` set to `provisioned` | `number` | `null` | no |
| <a name="input_replication_configuration_destination"></a> [replication\_configuration\_destination](#input\_replication\_configuration\_destination) | (Optional) A destination configuration block. Default is none. | `any` | `{}` | no |
| <a name="input_source_policy_documents"></a> [source\_policy\_documents](#input\_source\_policy\_documents) | (Optional) List of IAM policy documents that are merged together into the exported document. Statements must have unique `sid`s. Default is an empty list. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. Default is none. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_efs_arn"></a> [efs\_arn](#output\_efs\_arn) | ARN of the Anyscale Elastic File System (EFS) resource |
| <a name="output_efs_dns_name"></a> [efs\_dns\_name](#output\_efs\_dns\_name) | DNS Name for the Anyscale Elastic File System (EFS) resource |
| <a name="output_efs_id"></a> [efs\_id](#output\_efs\_id) | ID that identifies the Anyscale Elastic File System (EFS) resource |
| <a name="output_efs_mount_target_availability_zone_ids"></a> [efs\_mount\_target\_availability\_zone\_ids](#output\_efs\_mount\_target\_availability\_zone\_ids) | EFS mount target availability zone IDs |
| <a name="output_efs_mount_target_availability_zone_names"></a> [efs\_mount\_target\_availability\_zone\_names](#output\_efs\_mount\_target\_availability\_zone\_names) | EFS mount target availability zone names |
| <a name="output_efs_mount_target_ids"></a> [efs\_mount\_target\_ids](#output\_efs\_mount\_target\_ids) | EFS Mount Target IDs |
| <a name="output_efs_mount_target_ips"></a> [efs\_mount\_target\_ips](#output\_efs\_mount\_target\_ips) | EFS mount target IPs |
| <a name="output_efs_mount_target_network_interface_ids"></a> [efs\_mount\_target\_network\_interface\_ids](#output\_efs\_mount\_target\_network\_interface\_ids) | EFS mount target network interface IDs |
<!-- END_TF_DOCS -->

<!-- References -->
[Terraform]: https://www.terraform.io
[Anyscale]: https://www.anyscale.com
[Issues]: https://github.com/anyscale/terraform-aws-anyscale-cloudfoundation-modules/issues
[badge-release]: https://img.shields.io/github/v/release/anyscale/terraform-aws-anyscale-cloudfoundation-modules.svg?style=for-the-badge&labelColor=0066FF&color=CCE0FF
[badge-build]: https://img.shields.io/github/actions/workflow/status/anyscale/terraform-aws-anyscale-cloudfoundation-modules/main.yml?style=for-the-badge
[badge-terraform]: https://img.shields.io/badge/terraform-1.9.x+%20-623CE4.svg?logo=terraform&style=for-the-badge&labelColor=DDDDDD
[badge-tf-aws]: https://img.shields.io/badge/AWS-5.+-F8991D.svg?logo=terraform&style=for-the-badge&labelColor=DDDDDD
[badge-anyscale-cli]: https://img.shields.io/badge/anyscale%20cli-0.26.40+-0066FF.svg?style=for-the-badge&labelColor=CCE0FF&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAzIiBoZWlnaHQ9IjIwMyIgdmlld0JveD0iMCAwIDIwMyAyMDMiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxwYXRoIGQ9Ik0xNDMuNzg5IDEwNC42NzVMMTE2LjMyMyAxNTIuMjUySDE3MS42MzVDMTczLjY2NiAxNTIuMjUyIDE3NS41NDUgMTUxLjE3IDE3Ni41NyAxNDkuNDA1TDIwMi4zOTUgMTA0LjY3NUgxNDMuNzg5WiIgZmlsbD0iIzAwNjZGRiIvPgo8cGF0aCBkPSJNMjAyLjM5NSA5OC4zMjUzTDE3Ni41NyA1My41OTQ5QzE3NS41NTUgNTEuODI5NiAxNzMuNjc2IDUwLjc0NzYgMTcxLjYzNSA1MC43NDc2SDExNi4zMjNMMTQzLjc4OSA5OC4zMjUzSDIwMi4zOTVaIiBmaWxsPSIjMDA2NkZGIi8+CjxwYXRoIGQ9Ik02MS4zODk0IDUwLjc0NzZIMTE2LjMyMkw4OC42NjYxIDIuODQ3MjZDODcuNjUwNiAxLjA4MTk2IDg1Ljc3MTQgMCA4My43MzA5IDBIMzIuMDgxNkw2MS4zNzk5IDUwLjc0NzZINjEuMzg5NFoiIGZpbGw9IiMwMDY2RkYiLz4KPHBhdGggZD0iTTI2LjU4NjQgMy4xNjk5NUwwLjc2MTc2NCA0Ny45MDA0Qy0wLjI1Mzc1OCA0OS42NjU3IC0wLjI1Mzc1OCA1MS44Mjk2IDAuNzYxNzY0IDUzLjU5NDlMMjguNDE4MSAxMDEuNDk1TDU1Ljg4NDcgNTMuOTE3NkwyNi41ODY0IDMuMTY5OTVaIiBmaWxsPSIjMDA2NkZGIi8+CjxwYXRoIGQ9Ik01NS44OTQyIDE0OS4wNzNMMjguNDI3NiAxMDEuNDk1TDAuNzYxNzY0IDE0OS40MDVDLTAuMjUzNzU4IDE1MS4xNyAtMC4yNTM3NTggMTUzLjMzNCAwLjc2MTc2NCAxNTUuMUwyNi41ODY0IDE5OS44M0w1NS44ODQ3IDE0OS4wODJMNTUuODk0MiAxNDkuMDczWiIgZmlsbD0iIzAwNjZGRiIvPgo8cGF0aCBkPSJNMzIuMDgxNiAyMDNIODMuNzMwOUM4NS43NjE5IDIwMyA4Ny42NDExIDIwMS45MTggODguNjY2MSAyMDAuMTUzTDExNi4zMjIgMTUyLjI1Mkg2MS4zODk0TDMyLjA5MTEgMjAzSDMyLjA4MTZaIiBmaWxsPSIjMDA2NkZGIi8+Cjwvc3ZnPg==
[build-status]: https://github.com/anyscale/terraform-aws-anyscale-cloudfoundation-modules/actions
