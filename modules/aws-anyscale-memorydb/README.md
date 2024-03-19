[![Build Status][badge-build]][build-status]
[![Terraform Version][badge-terraform]](https://github.com/hashicorp/terraform/releases)
[![AWS Provider Version][badge-tf-aws]](https://github.com/terraform-providers/terraform-provider-aws/releases)

# aws-anyscale-memorydb

This sub-module creates AWS MemoryDB resource that are used for Anyscale Services HA (head node failures).  It should be used from the [root module](../../README.md).

AWS MemoryDB for Redis is a fully managed, in-memory database service built on the popular Redis engine. It provides fast performance, scalability, and durability for use cases that demand high-speed access to data. MemoryDB is designed to offer a fault-tolerant system by replicating data across multiple Availability Zones, ensuring data persistence without sacrificing latency.

This is an optional module and should only be used if you are planning to implement Anyscale Services for production workloads.
Enabling this submodule will increase the deployment time for these modules - this module will take between 15 and 30 minutes to complete.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.41.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_memorydb_acl.anyscale_memorydb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/memorydb_acl) | resource |
| [aws_memorydb_cluster.anyscale_memorydb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/memorydb_cluster) | resource |
| [aws_memorydb_parameter_group.anyscale_memorydb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/memorydb_parameter_group) | resource |
| [aws_memorydb_subnet_group.anyscale_memorydb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/memorydb_subnet_group) | resource |
| [aws_memorydb_user.anyscale_memorydb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/memorydb_user) | resource |
| [random_id.parameter_group_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_memorydb_security_group_ids"></a> [memorydb\_security\_group\_ids](#input\_memorydb\_security\_group\_ids) | (Required) A list of security group IDs<br><br>This should be existing Security Group IDs or from the `aws-anyscale-securitygroups` sub module. These security groups will be associated with the MemoryDB cluster.<br><br>ex:<pre>memorydb_security_group_ids = [<br>  "sg-1234567890",<br>  "sg-0987654321"<br>]</pre> | `list(string)` | n/a | yes |
| <a name="input_memorydb_subnet_ids"></a> [memorydb\_subnet\_ids](#input\_memorydb\_subnet\_ids) | (Required) A list of subnet IDs<br><br>This should be existing Subnet IDs or from the `aws-anyscale-vpc` sub module. These subnets will be associated with the MemoryDB subnet group.<br><br>ex:<pre>memorydb_subnet_ids = [<br>  "subnet-1234567890",<br>  "subnet-0987654321"<br>]</pre> | `list(string)` | n/a | yes |
| <a name="input_anyscale_cloud_id"></a> [anyscale\_cloud\_id](#input\_anyscale\_cloud\_id) | (Optional) Anyscale Cloud ID.<br><br>Used in Tags and Permissions.<br><br>ex:<pre>anyscale_cloud_id = "cld_1234567890"</pre> | `string` | `null` | no |
| <a name="input_anyscale_memorydb_description"></a> [anyscale\_memorydb\_description](#input\_anyscale\_memorydb\_description) | (Optional) A description of the secret<br><br>This should be a meaningful description of the Memory DB.<br><br>ex:<pre>anyscale_memorydb_description = "Anyscale MemoryDB for Anyscale Services"</pre> | `string` | `"Anyscale managed MemoryDB for Anyscale Services"` | no |
| <a name="input_anyscale_memorydb_name"></a> [anyscale\_memorydb\_name](#input\_anyscale\_memorydb\_name) | (Optional) Name for the Anyscale Memory DB.<br><br>If left `null`, will default to `anyscale_memorydb_name_prefix`.<br>If provided, overrides the `anyscale_memorydb_name_prefix` variable.<br><br>ex:<pre>anyscale_memorydb_name = "anyscale-memorydb"</pre> | `string` | `null` | no |
| <a name="input_anyscale_memorydb_name_prefix"></a> [anyscale\_memorydb\_name\_prefix](#input\_anyscale\_memorydb\_name\_prefix) | (Optional) Name prefix for the Anyscale Memory DB.<br><br>If `anyscale_memorydb_name` is provided, it will override this variable.<br>Default is `null` but is set to `anyscale-mdb-` in a local variable.<br><br>ex:<pre>anyscale_memorydb_name_prefix = "anyscale-mdb-"</pre> | `string` | `null` | no |
| <a name="input_create_memorydb_acl"></a> [create\_memorydb\_acl](#input\_create\_memorydb\_acl) | (Optional) Determines if a MemoryDB ACL should be created.<br><br>If `false`, the `existing_memorydb_acl_name` variable must be set.<br><br>ex:<pre>create_memorydb_acl = true</pre> | `bool` | `false` | no |
| <a name="input_create_memorydb_parameter_group"></a> [create\_memorydb\_parameter\_group](#input\_create\_memorydb\_parameter\_group) | (Optional) Determines if a MemoryDB parameter group should be created.<br><br>If `false`, the `existing_memorydb_parameter_group_name` variable must be set.<br><br>ex:<pre>create_memorydb_parameter_group = true</pre> | `bool` | `true` | no |
| <a name="input_create_memorydb_subnet_group"></a> [create\_memorydb\_subnet\_group](#input\_create\_memorydb\_subnet\_group) | (Optional) Determines if a MemoryDB subnet group should be created.<br><br>If `false`, the `existing_memorydb_subnet_group_name` variable must be set.<br><br>ex:<pre>create_memorydb_subnet_group = true</pre> | `bool` | `true` | no |
| <a name="input_create_memorydb_users"></a> [create\_memorydb\_users](#input\_create\_memorydb\_users) | (Optional) Determines if MemoryDB users should be created.<br><br>ex:<pre>create_memorydb_users = true</pre> | `bool` | `false` | no |
| <a name="input_enable_auto_minor_version_upgrade"></a> [enable\_auto\_minor\_version\_upgrade](#input\_enable\_auto\_minor\_version\_upgrade) | (Optional) Determines if minor engine upgrades will be applied automatically<br><br>This only applies to the underlying MemoryDB cluster during the maintenance window.<br><br>ex:<pre>enable_auto_minor_version_upgrade = true</pre> | `bool` | `true` | no |
| <a name="input_enable_memorydb_data_tiering"></a> [enable\_memorydb\_data\_tiering](#input\_enable\_memorydb\_data\_tiering) | (Optional) Determines if data tiering is enabled.<br><br>ex:<pre>enable_memorydb_data_tiering = false</pre> | `string` | `false` | no |
| <a name="input_existing_memorydb_acl_name"></a> [existing\_memorydb\_acl\_name](#input\_existing\_memorydb\_acl\_name) | (Optional) The name of an existing MemoryDB ACL to use.<br><br>If not provided, `create_memorydb_acl` must be set to `true` and a new MemoryDB ACL will be created.<br>If this is provided, `create_memorydb_acl` must be set to `false`.<br><br>ex:<pre>existing_memorydb_acl_name = "open-access"</pre> | `string` | `"open-access"` | no |
| <a name="input_existing_memorydb_parameter_group_name"></a> [existing\_memorydb\_parameter\_group\_name](#input\_existing\_memorydb\_parameter\_group\_name) | (Optional) The name of an existing MemoryDB parameter group to use.<br><br>If not provided, `create_memorydb_parameter_group` must be set to `true` and a new MemoryDB parameter group will be created.<br>If this is provided, `create_memorydb_parameter_group` must be set to `false`.<br><br>ex:<pre>existing_memorydb_parameter_group_name = "anyscale-memorydb-parameter-group"</pre> | `string` | `null` | no |
| <a name="input_existing_memorydb_subnet_group_name"></a> [existing\_memorydb\_subnet\_group\_name](#input\_existing\_memorydb\_subnet\_group\_name) | (Optional) The name of an existing MemoryDB subnet group to use.<br><br>If not provided, `create_memorydb_subnet_group` must be set to `true` and a new MemoryDB subnet group will be created.<br>If this is provided, `create_memorydb_subnet_group` must be set to `false`.<br><br>ex:<pre>existing_memorydb_subnet_group_name = "anyscale-memorydb-subnet-group"</pre> | `string` | `null` | no |
| <a name="input_memorydb_acl_name"></a> [memorydb\_acl\_name](#input\_memorydb\_acl\_name) | (Optional) Name for the MemoryDB ACL.<br><br>If left `null`, will default to `anyscale_memorydb_name_prefix`.<br>If provided, overrides the `anyscale_memorydb_name_prefix` variable.<br><br>ex:<pre>memorydb_acl_name = "anyscale-memorydb-acl"</pre> | `string` | `null` | no |
| <a name="input_memorydb_acl_name_prefix"></a> [memorydb\_acl\_name\_prefix](#input\_memorydb\_acl\_name\_prefix) | (Optional) Name prefix for the MemoryDB ACL.<br><br>If `memorydb_acl_name` is provided, it will override this variable.<br>Default is `null` but is set to `anyscale-mdb-acl-` in a local variable.<br><br>ex:<pre>memorydb_acl_name_prefix = "anyscale-mdb-acl-"</pre> | `string` | `null` | no |
| <a name="input_memorydb_acl_tags"></a> [memorydb\_acl\_tags](#input\_memorydb\_acl\_tags) | (Optional) A map of tags to be added to the MemoryDB ACL.<br><br>Duplicate tags in `tags` and `memorydb_acl_tags` will be overwritten.<br><br>ex:<pre>memorydb_acl_tags = {<br>  application = "Anyscale",<br>  environment = "prod"<br>}</pre> | `map(string)` | `{}` | no |
| <a name="input_memorydb_acl_user_names"></a> [memorydb\_acl\_user\_names](#input\_memorydb\_acl\_user\_names) | (Optional) A list of user names to be added to the MemoryDB ACL.<br><br>ex:<pre>memorydb_acl_user_names = [<br>  "admin",<br>  "readonly"<br>]</pre> | `list(string)` | `[]` | no |
| <a name="input_memorydb_engine_version"></a> [memorydb\_engine\_version](#input\_memorydb\_engine\_version) | (Optional) The version number of the Redis engine to be used.<br><br>The following are the supported versions:<br><br>* `7.0`<br>* `6.2`<br><br>ex:<pre>memorydb_engine_version = "7.0"</pre> | `string` | `"7.0"` | no |
| <a name="input_memorydb_final_snapshot_name"></a> [memorydb\_final\_snapshot\_name](#input\_memorydb\_final\_snapshot\_name) | (Optional) The name of a final snapshot to be taken immediately before deleting the cluster.<br><br>ex:<pre>memorydb_final_snapshot_name = "anyscale-memorydb-final-snapshot"</pre> | `string` | `null` | no |
| <a name="input_memorydb_kms_key_arn"></a> [memorydb\_kms\_key\_arn](#input\_memorydb\_kms\_key\_arn) | (Optional) KMS Key ARN or Id<br><br>AWS KMS key to be used to encrypt the MemoryDB.<br>If you don't specify this value, then MemoryDB defaults to using the AWS account's default KMS key.<br><br>ex:<pre>kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"</pre> | `string` | `null` | no |
| <a name="input_memorydb_maintenance_window"></a> [memorydb\_maintenance\_window](#input\_memorydb\_maintenance\_window) | (Optional) The weekly time range (in UTC) during which system maintenance can occur.<br><br>Please remember that the maintenance window and the snapshot window cannot overlap.<br><br>ex:<pre>memorydb_maintenance_window = "sun:05:00-sun:09:00"</pre> | `string` | `null` | no |
| <a name="input_memorydb_node_type"></a> [memorydb\_node\_type](#input\_memorydb\_node\_type) | (Optional) The node types to use in the MemoryDB.<br><br>The node type helps define the compute and memory capacity of the nodes in the node group.<br><br>ex:<pre>memorydb_node_type = "db.t4g.small"</pre> | `string` | `"db.t4g.small"` | no |
| <a name="input_memorydb_num_replicas_per_shard"></a> [memorydb\_num\_replicas\_per\_shard](#input\_memorydb\_num\_replicas\_per\_shard) | (Optional) The number of replicas per shard.<br><br>ex:<pre>memorydb_num_replicas_per_shard = 2</pre> | `number` | `2` | no |
| <a name="input_memorydb_num_shards"></a> [memorydb\_num\_shards](#input\_memorydb\_num\_shards) | (Optional) The number of shards in the cluster.<br><br>ex:<pre>memorydb_num_shards = 1</pre> | `number` | `1` | no |
| <a name="input_memorydb_parameter_group_description"></a> [memorydb\_parameter\_group\_description](#input\_memorydb\_parameter\_group\_description) | (Optional) A description of the MemoryDB parameter group.<br><br>This should be a meaningful description of the MemoryDB parameter group.<br><br>ex:<pre>memorydb_parameter_group_description = "Anyscale MemoryDB Parameter Group for Anyscale Services"</pre> | `string` | `"Anyscale MemoryDB Parameter Group for Anyscale Services"` | no |
| <a name="input_memorydb_parameter_group_family"></a> [memorydb\_parameter\_group\_family](#input\_memorydb\_parameter\_group\_family) | (Optional) The family of the MemoryDB parameter group.<br><br>The following are the supported families:<br><br>* `memorydb_redis7`<br>* `memorydb_redis6`<br>* `memorydb_redis5`<br><br>ex:<pre>memorydb_parameter_group_family = "memorydb_redis7"</pre> | `string` | `"memorydb_redis7"` | no |
| <a name="input_memorydb_parameter_group_name"></a> [memorydb\_parameter\_group\_name](#input\_memorydb\_parameter\_group\_name) | (Optional) Name for the MemoryDB parameter group.<br><br>If left `null`, will default to `anyscale_memorydb_name_prefix`.<br>If provided, overrides the `anyscale_memorydb_name_prefix` variable.<br><br>ex:<pre>memorydb_parameter_group_name = "anyscale-memorydb-parameter-group"</pre> | `string` | `null` | no |
| <a name="input_memorydb_parameter_group_name_prefix"></a> [memorydb\_parameter\_group\_name\_prefix](#input\_memorydb\_parameter\_group\_name\_prefix) | (Optional) Name prefix for the MemoryDB parameter group.<br><br>If `memorydb_parameter_group_name` is provided, it will override this variable.<br>Default is `null` but is set to `anyscale-mdb-pg-` in a local variable.<br><br>ex:<pre>memorydb_parameter_group_name_prefix = "anyscale-mdb-pg-"</pre> | `string` | `null` | no |
| <a name="input_memorydb_parameter_group_parameters"></a> [memorydb\_parameter\_group\_parameters](#input\_memorydb\_parameter\_group\_parameters) | (Optional) A list of parameters to be added to the MemoryDB parameter group.<br><br>ex:<pre>memorydb_parameter_group_parameters = [<br>  {<br>    name  = "maxmemory-policy"<br>    value = "allkeys-lru"<br>  },<br>  {<br>    name  = "activedefrag"<br>    value = "yes"<br>  }<br>]</pre> | <pre>list(object({<br>    name  = string<br>    value = string<br>  }))</pre> | <pre>[<br>  {<br>    "name": "maxmemory-policy",<br>    "value": "allkeys-lru"<br>  }<br>]</pre> | no |
| <a name="input_memorydb_parameter_group_tags"></a> [memorydb\_parameter\_group\_tags](#input\_memorydb\_parameter\_group\_tags) | (Optional) A map of tags to be added to the MemoryDB parameter group.<br><br>Duplicate tags in `tags` and `memorydb_parameter_group_tags` will be overwritten.<br><br>ex:<pre>memorydb_parameter_group_tags = {<br>  application = "Anyscale",<br>  environment = "prod"<br>}</pre> | `map(string)` | `{}` | no |
| <a name="input_memorydb_port"></a> [memorydb\_port](#input\_memorydb\_port) | (Optional) The port number on which each of the nodes accepts connections.<br><br>The default is `6379`.<br><br>ex:<pre>memorydb_port = 6379</pre> | `number` | `6379` | no |
| <a name="input_memorydb_snapshot_retention_limit"></a> [memorydb\_snapshot\_retention\_limit](#input\_memorydb\_snapshot\_retention\_limit) | (Optional) The number of days for which MemoryDB retains automatic snapshots before deleting them.<br><br>ex:<pre>snapshot_retention_limit = 7</pre> | `number` | `null` | no |
| <a name="input_memorydb_snapshot_window"></a> [memorydb\_snapshot\_window](#input\_memorydb\_snapshot\_window) | (Optional) The daily time range (in UTC) during which MemoryDB begins taking a daily snapshot of your shard.<br><br>Please remember that the snapshot window and the maintenance window can not overlap.<br><br>ex:<pre>memorydb_snapshot_window = "05:00-09:00"</pre> | `string` | `null` | no |
| <a name="input_memorydb_sns_topic_arn"></a> [memorydb\_sns\_topic\_arn](#input\_memorydb\_sns\_topic\_arn) | (Optional) The ARN of the SNS topic to send MemoryDB events to.<br><br>ex:<pre>memorydb_sns_topic_arn = "arn:aws:sns:us-east-1:123456789012:anyscale-memorydb-events"</pre> | `string` | `null` | no |
| <a name="input_memorydb_subnet_group_description"></a> [memorydb\_subnet\_group\_description](#input\_memorydb\_subnet\_group\_description) | (Optional) A description of the MemoryDB subnet group.<br><br>This should be a meaningful description of the MemoryDB subnet group.<br><br>ex:<pre>memorydb_subnet_group_description = "Anyscale MemoryDB Subnet Group for Anyscale Services"</pre> | `string` | `"Anyscale MemoryDB Subnet Group for Anyscale Services"` | no |
| <a name="input_memorydb_subnet_group_name"></a> [memorydb\_subnet\_group\_name](#input\_memorydb\_subnet\_group\_name) | (Optional) Name for the MemoryDB subnet group.<br><br>If left `null`, will default to `anyscale_memorydb_name_prefix`.<br>If provided, overrides the `anyscale_memorydb_name_prefix` variable.<br><br>ex:<pre>memorydb_subnet_group_name = "anyscale-mdb-sg"</pre> | `string` | `null` | no |
| <a name="input_memorydb_subnet_group_name_prefix"></a> [memorydb\_subnet\_group\_name\_prefix](#input\_memorydb\_subnet\_group\_name\_prefix) | (Optional) Name prefix for the MemoryDB subnet group.<br><br>If `memorydb_subnet_group_name` is provided, it will override this variable.<br>Default is `null` but is set to `anyscale-mdb-sg-` in a local variable.<br><br>ex:<pre>memorydb_subnet_group_name_prefix = "anyscale-mdb-sg-"</pre> | `string` | `null` | no |
| <a name="input_memorydb_subnet_group_tags"></a> [memorydb\_subnet\_group\_tags](#input\_memorydb\_subnet\_group\_tags) | (Optional) A map of tags to be added to the MemoryDB subnet group.<br><br>Duplicate tags in `tags` and `memorydb_subnet_group_tags` will be overwritten.<br><br>ex:<pre>memorydb_subnet_group_tags = {<br>  application = "Anyscale",<br>  environment = "prod"<br>}</pre> | `map(string)` | `{}` | no |
| <a name="input_memorydb_tls_enabled"></a> [memorydb\_tls\_enabled](#input\_memorydb\_tls\_enabled) | (Optional) Determines if TLS encryption is enabled.<br><br>ex:<pre>memorydb_tls_enabled = true</pre> | `bool` | `true` | no |
| <a name="input_memorydb_users"></a> [memorydb\_users](#input\_memorydb\_users) | (Optional) A map of MemoryDB users to be created.<br><br>ex:<pre>memorydb_users = {<br>  admin = {<br>    user_name     = "admin-user"<br>    access_string = "on ~* &* +@all"<br>    passwords     = [random_password.password["admin"].result]<br>    tags          = { user = "admin" }<br>  }<br>  readonly = {<br>    user_name     = "readonly-user"<br>    access_string = "on ~* &* -@all +@read"<br>    passwords     = [random_password.password["readonly"].result]<br>    tags          = { user = "readonly" }<br>  }<br>}</pre> | `map(any)` | `{}` | no |
| <a name="input_module_enabled"></a> [module\_enabled](#input\_module\_enabled) | (Optional) Determines if this module is enabled and resources are created.<br><br>ex:<pre>module_enabled = false</pre> | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to be added.<br><br>ex:<pre>tags = {<br>  application = "Anyscale",<br>  environment = "prod"<br>}</pre> | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_memorydb_acl_arn"></a> [memorydb\_acl\_arn](#output\_memorydb\_acl\_arn) | The ARN of the MemoryDB ACL |
| <a name="output_memorydb_acl_id"></a> [memorydb\_acl\_id](#output\_memorydb\_acl\_id) | Name of the MemoryDB ACL |
| <a name="output_memorydb_cluster_arn"></a> [memorydb\_cluster\_arn](#output\_memorydb\_cluster\_arn) | MemoryDB Cluster ARN |
| <a name="output_memorydb_cluster_endpoint_address"></a> [memorydb\_cluster\_endpoint\_address](#output\_memorydb\_cluster\_endpoint\_address) | DNS hostname of the cluster configuration endpoint |
| <a name="output_memorydb_cluster_endpoint_port"></a> [memorydb\_cluster\_endpoint\_port](#output\_memorydb\_cluster\_endpoint\_port) | Port number that the cluster configuration endpoint is listening on |
| <a name="output_memorydb_cluster_id"></a> [memorydb\_cluster\_id](#output\_memorydb\_cluster\_id) | MemoryDB Cluster Name |
| <a name="output_memorydb_cluster_shards"></a> [memorydb\_cluster\_shards](#output\_memorydb\_cluster\_shards) | Set of shards in this cluster |
| <a name="output_memorydb_parameter_group_arn"></a> [memorydb\_parameter\_group\_arn](#output\_memorydb\_parameter\_group\_arn) | The ARN of the MemoryDB parameter group |
| <a name="output_memorydb_parameter_group_id"></a> [memorydb\_parameter\_group\_id](#output\_memorydb\_parameter\_group\_id) | Name of the MemoryDB parameter group |
| <a name="output_memorydb_subnet_group_id"></a> [memorydb\_subnet\_group\_id](#output\_memorydb\_subnet\_group\_id) | Name of the MemoryDB subnet group |
| <a name="output_subnet_group_arn"></a> [subnet\_group\_arn](#output\_subnet\_group\_arn) | ARN of the MemoryDB subnet group |
| <a name="output_subnet_group_vpc_id"></a> [subnet\_group\_vpc\_id](#output\_subnet\_group\_vpc\_id) | The VPC in which the MemoryDB subnet group exists |
| <a name="output_users"></a> [users](#output\_users) | Map of attributes for the users created |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- References -->
[Terraform]: https://www.terraform.io
[Issues]: https://github.com/anyscale/sa-sandbox-terraform/issues
[badge-build]: https://github.com/anyscale/sa-sandbox-terraform/workflows/CI/CD%20Pipeline/badge.svg
[badge-terraform]: https://img.shields.io/badge/terraform-1.x%20-623CE4.svg?logo=terraform
[badge-tf-aws]: https://img.shields.io/badge/AWS-5.+-F8991D.svg?logo=terraform
[build-status]: https://github.com/anyscale/sa-sandbox-terraform/actions
