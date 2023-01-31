[![Build Status][badge-build]][build-status]
[![Terraform Version][badge-terraform]](https://github.com/hashicorp/terraform/releases)
[![AWS Provider Version][badge-tf-aws]](https://github.com/terraform-providers/terraform-provider-aws/releases)

# Terraform Modules for Anyscale Cloud Foundations
[Terraform] modules to manage cloud infrastructure for Anyscale. This builds the foundational cloud resources needed to run Anyscale
in a cloud environment. It currently supports AWS with Google Cloud support coming soon.

**THIS IS PROVIDED AS A STARTING POINT AND IS CONSIDERED BETA**

**USE AT YOUR OWN RISK**

## AWS Cloud Resources
The minimum resources needed to run Anyscale on AWS are [documented here](https://docs.anyscale.com/user-guide/onboard/clouds#resource-requirements).
To support this, sob-modules were created to allow easier long-term management of the resources. These include:
* aws-anyscale-vpc - This builds a rudimentary VPC
* aws-anyscale-securitygroups - This builds security groups that are applied to Anyscale Clusters and the EFS storage.
* aws-anyscale-s3 - This builds a S3 bucket which is used by Anyscale to store cluster logs and shared resources.
* aws-anyscale-s3-policy - This builds a S3 bucket policy which has dependencies on aws-anyscale-iam
* aws-anyscale-iam - This builds IAM roles and policies. One role for cross-account access from the Anyscale control plane, and one role for EC2 instance profiles.
* aws-anyscale-efs - This builds an EFS storage and associated mount points.

At a high level, every module can be disabled - however it is then up to the end user to build that particular resource. This is probably most
common with the network (VPC), but end users might also have custom S3, IAM, EFS, etc scripts that they already want to use, or specific security
requirements that they've already implemented and just need to plug in the remaining items.

### Examples
The examples folder has a couple common use cases that have been tested. These include:
* Build everything - this mimics the existing cloudformation script, but in Terraform.
* Pass in an existing VPC and Subnets - build everything else.

Additional examples can be requested via a [issues] ticket.

## Reporting Issues

We use GitHub [Issues] to track community reported issues and missing features.

## Known Issues/Untested

v2 Stack is currently untested.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_anyscale_efs"></a> [aws\_anyscale\_efs](#module\_aws\_anyscale\_efs) | ./modules/aws-anyscale-efs | n/a |
| <a name="module_aws_anyscale_iam"></a> [aws\_anyscale\_iam](#module\_aws\_anyscale\_iam) | ./modules/aws-anyscale-iam | n/a |
| <a name="module_aws_anyscale_s3"></a> [aws\_anyscale\_s3](#module\_aws\_anyscale\_s3) | ./modules/aws-anyscale-s3 | n/a |
| <a name="module_aws_anyscale_s3_policy"></a> [aws\_anyscale\_s3\_policy](#module\_aws\_anyscale\_s3\_policy) | ./modules/aws-anyscale-s3-policy | n/a |
| <a name="module_aws_anyscale_securitygroup_self"></a> [aws\_anyscale\_securitygroup\_self](#module\_aws\_anyscale\_securitygroup\_self) | ./modules/aws-anyscale-securitygroups | n/a |
| <a name="module_aws_anyscale_vpc"></a> [aws\_anyscale\_vpc](#module\_aws\_anyscale\_vpc) | ./modules/aws-anyscale-vpc | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_anyscale_cloud_id"></a> [anyscale\_cloud\_id](#input\_anyscale\_cloud\_id) | (Optional) Anyscale Cloud ID. Default is `null`. | `string` | `null` | no |
| <a name="input_anyscale_deploy_env"></a> [anyscale\_deploy\_env](#input\_anyscale\_deploy\_env) | (Required) Anyscale deploy environment. Used in resource names and tags. | `string` | n/a | yes |
| <a name="input_anyscale_iam_access_role_name"></a> [anyscale\_iam\_access\_role\_name](#input\_anyscale\_iam\_access\_role\_name) | (Optional, forces creation of new resource)<br>The name of the Anyscale IAM access role.<br>If left `null`, will default to anyscale\_iam\_access\_role\_name\_prefix.<br>If provided, overrides the anyscale\_iam\_access\_role\_name\_prefix variable.<br>Default is `null`. | `string` | `null` | no |
| <a name="input_anyscale_iam_access_role_name_prefix"></a> [anyscale\_iam\_access\_role\_name\_prefix](#input\_anyscale\_iam\_access\_role\_name\_prefix) | (Optional, forces creation of new resource)<br>The prefix for the Anyscale IAM access role.<br>The variable, anyscale\_iam\_access\_role\_name, will override this variable.<br>Default is `anyscale-iam-role-`. | `string` | `"anyscale-iam-role-"` | no |
| <a name="input_anyscale_iam_cluster_node_role_name"></a> [anyscale\_iam\_cluster\_node\_role\_name](#input\_anyscale\_iam\_cluster\_node\_role\_name) | (Optional, forces creation of new resource)<br>The name of the Anyscale IAM cluster node role.<br>If left `null`, will default to anyscale\_iam\_access\_role\_name\_prefix.<br>Default is `null`. | `string` | `null` | no |
| <a name="input_anyscale_iam_cluster_node_role_name_prefix"></a> [anyscale\_iam\_cluster\_node\_role\_name\_prefix](#input\_anyscale\_iam\_cluster\_node\_role\_name\_prefix) | (Optional, forces creation of new resource)<br>The prefix of the Anyscale Cluster Node IAM role.<br>The variable, anyscale\_iam\_cluster\_node\_role\_name, will override this variable.<br>Default is `anyscale-cluster-node-`. | `string` | `"anyscale-cluster-node-"` | no |
| <a name="input_anyscale_s3_bucket_name"></a> [anyscale\_s3\_bucket\_name](#input\_anyscale\_s3\_bucket\_name) | (Optional - forces new resource)<br>The name of the bucket used to store Anyscale related logs and other shared resources.<br>If left `null`, will default to anyscale\_s3\_bucket\_prefix.<br>If provided, overrides the anyscale\_s3\_bucket\_prefix variable.<br>Conflicts with anyscale\_bucket\_prefix. Default is `null`. | `string` | `null` | no |
| <a name="input_anyscale_s3_bucket_prefix"></a> [anyscale\_s3\_bucket\_prefix](#input\_anyscale\_s3\_bucket\_prefix) | (Optional - forces new resource)<br>Creates a unique bucket name beginning with the specified prefix.<br>If `anyscale_s3_bucket_name` is provided, it will override this variable.<br>Default is `anyscale-`. | `string` | `"anyscale-"` | no |
| <a name="input_anyscale_vpc_cidr_block"></a> [anyscale\_vpc\_cidr\_block](#input\_anyscale\_vpc\_cidr\_block) | (Optional) The IPv4 CIDR block for the VPC. CIDR can be explicitly set or it can be derived from IPAM using `ipv4_netmask_length` & `ipv4_ipam_pool_id`. Default is `10.0.0.0/16` | `string` | `"10.0.0.0/16"` | no |
| <a name="input_anyscale_vpc_name"></a> [anyscale\_vpc\_name](#input\_anyscale\_vpc\_name) | (Optional) VPC name. Will default to `vpc_<anyscale_cloud_id>`. | `string` | `null` | no |
| <a name="input_anyscale_vpc_private_subnets"></a> [anyscale\_vpc\_private\_subnets](#input\_anyscale\_vpc\_private\_subnets) | (Optional) A list of private subnets inside the VPC. Default is an empty list. | `list(string)` | `[]` | no |
| <a name="input_anyscale_vpc_public_subnets"></a> [anyscale\_vpc\_public\_subnets](#input\_anyscale\_vpc\_public\_subnets) | (Optional) A list of public subnets inside the VPC. Default is an empty list. | `list(string)` | `[]` | no |
| <a name="input_cloud_provider"></a> [cloud\_provider](#input\_cloud\_provider) | (Required) Which cloud provider would you like to run this module on? Valid options are `aws` or `gcp`. Default is `aws`. | `string` | `"aws"` | no |
| <a name="input_efs_creation_token"></a> [efs\_creation\_token](#input\_efs\_creation\_token) | (Optional) A unique token used as reference when creating the Elastic File System to ensure idempotent file system creation.<br>Default is `null` which forces Terraform to generate it. | `string` | `null` | no |
| <a name="input_efs_lifecycle_transition_to_ia"></a> [efs\_lifecycle\_transition\_to\_ia](#input\_efs\_lifecycle\_transition\_to\_ia) | (Optional) Indicates how long it takes to transition files to Infrequent Access storage class.<br>No value, or an empty list, means never.<br>Must either be an empty list or one of "AFTER\_7\_DAYS", "AFTER\_14\_DAYS", "AFTER\_30\_DAYS", "AFTER\_60\_DAYS", "AFTER\_90\_DAYS".<br>Default is `AFTER_60_DAYS` which will transition to IA after 60 days. | `list(string)` | <pre>[<br>  "AFTER_60_DAYS"<br>]</pre> | no |
| <a name="input_efs_lifecycle_transition_to_primary_storage_class"></a> [efs\_lifecycle\_transition\_to\_primary\_storage\_class](#input\_efs\_lifecycle\_transition\_to\_primary\_storage\_class) | (Optional) Indicates the policy used to transition a file from Infrequent Access (IA) storage to primary storage.<br>Must either be an empty list or `AFTER_1_ACCESS`.<br>Default is `AFTER_1_ACCESS`. | `list(string)` | <pre>[<br>  "AFTER_1_ACCESS"<br>]</pre> | no |
| <a name="input_efs_name"></a> [efs\_name](#input\_efs\_name) | (Optional) Elastic file system name. Will default to `efs_anyscale` if this var `null` and anyscale\_cloud\_id is also `null`.<br>Default is `null`. | `string` | `null` | no |
| <a name="input_existing_subnet_ids"></a> [existing\_subnet\_ids](#input\_existing\_subnet\_ids) | (Optional) Existing subnet IDs to create Anyscale resources in. If provided, this will skip creating resources with the Anyscale VPC module. VPC ID is also required is this is provided. Default is an empty list. | `list(string)` | `[]` | no |
| <a name="input_existing_vpc_id"></a> [existing\_vpc\_id](#input\_existing\_vpc\_id) | (Optional) An existing VPC ID. If provided, this will skip creating resources with the Anyscale VPC module. Subnet IDs is also required if this is provided. Default is `null`. | `string` | `null` | no |
| <a name="input_security_group_create_anyscale_public_ingress"></a> [security\_group\_create\_anyscale\_public\_ingress](#input\_security\_group\_create\_anyscale\_public\_ingress) | (Optional) Determines if public ingress rules should be created. Default is `false`. | `bool` | `false` | no |
| <a name="input_security_group_ingress_allow_access_from_cidr_range"></a> [security\_group\_ingress\_allow\_access\_from\_cidr\_range](#input\_security\_group\_ingress\_allow\_access\_from\_cidr\_range) | (Required) Comma delimited string of IPv4 CIDR range to allow access to anyscale resources.<br>This should be the list of CIDR ranges that have access to the clusters. If using Anyscale v1,<br>this should be public IPs. If using Anyscale v2, public or private IPs are supported. SSH and HTTPs<br>ports will be opened to these CIDR ranges.<br>ex: "10.0.1.0/24,24.1.24.24/32" | `string` | n/a | yes |
| <a name="input_security_group_ingress_with_existing_security_groups_map"></a> [security\_group\_ingress\_with\_existing\_security\_groups\_map](#input\_security\_group\_ingress\_with\_existing\_security\_groups\_map) | (Optional) List of security groups and rules to allow ingress from. Default is an empty list. | `list(map(string))` | `[]` | no |
| <a name="input_security_group_name"></a> [security\_group\_name](#input\_security\_group\_name) | (Optional) The name for the security group. If provided, overrides the security\_group\_name\_prefix.<br>Default is `null`. | `string` | `null` | no |
| <a name="input_security_group_name_prefix"></a> [security\_group\_name\_prefix](#input\_security\_group\_name\_prefix) | (Optional) The name prefix for the security group. Conflicts with security\_group\_name. Default is `anyscale-security-group-`. | `string` | `"anyscale-security-group-"` | no |
| <a name="input_security_group_override_ingress_from_cidr_map"></a> [security\_group\_override\_ingress\_from\_cidr\_map](#input\_security\_group\_override\_ingress\_from\_cidr\_map) | (Optional) List of ingress rules to create with cidr ranges.<br>If this variable is provided/populated, the default rules will not be created. At a minimum, https and ssh need<br>to be allowed from a IPv4 CIDR block that allows access for the users who are using Anyscale.<br>Default is an empty list. | `list(map(string))` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to all resources that accept tags. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_anyscale_efs_arn"></a> [anyscale\_efs\_arn](#output\_anyscale\_efs\_arn) | Anyscale Elastic File System ARN. If an EFS resource was not created, return an empty string. |
| <a name="output_anyscale_efs_id"></a> [anyscale\_efs\_id](#output\_anyscale\_efs\_id) | Anyscale Elastic File System ID. If an EFS resource was not created, return an empty string. |
| <a name="output_anyscale_efs_mount_target_ids"></a> [anyscale\_efs\_mount\_target\_ids](#output\_anyscale\_efs\_mount\_target\_ids) | Anyscale Elastic File System mount target IDs. If EFS mount targets were not created, return an empty list. |
| <a name="output_anyscale_iam_instance_profile_role_arn"></a> [anyscale\_iam\_instance\_profile\_role\_arn](#output\_anyscale\_iam\_instance\_profile\_role\_arn) | Anyscale IAM instance profile role arn. |
| <a name="output_anyscale_iam_role_arn"></a> [anyscale\_iam\_role\_arn](#output\_anyscale\_iam\_role\_arn) | Anyscale IAM access role arn. |
| <a name="output_anyscale_iam_role_cluster_node_arn"></a> [anyscale\_iam\_role\_cluster\_node\_arn](#output\_anyscale\_iam\_role\_cluster\_node\_arn) | Anyscale IAM cluster node role arn. |
| <a name="output_anyscale_s3_bucket_id"></a> [anyscale\_s3\_bucket\_id](#output\_anyscale\_s3\_bucket\_id) | Anyscale S3 Bucket ID. If a bucket was not created, return an empty string. |
| <a name="output_anyscale_security_group_id"></a> [anyscale\_security\_group\_id](#output\_anyscale\_security\_group\_id) | Anyscale Security Group ID. If a security group was not created, return an empty string. |
| <a name="output_anyscale_vpc_id"></a> [anyscale\_vpc\_id](#output\_anyscale\_vpc\_id) | Anyscale VPC ID. If there was not one created, return the one that was used during other resource creation. |
| <a name="output_anyscale_vpc_private_subnet_ids"></a> [anyscale\_vpc\_private\_subnet\_ids](#output\_anyscale\_vpc\_private\_subnet\_ids) | Anyscale VPC Private Subnet IDs. If there were none created, return an empty string. |
| <a name="output_anyscale_vpc_public_subnet_ids"></a> [anyscale\_vpc\_public\_subnet\_ids](#output\_anyscale\_vpc\_public\_subnet\_ids) | Anyscale VPC Public Subnet IDs. If there were none created, return an empty string. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- References -->
[Terraform]: https://www.terraform.io
[Issues]: https://github.com/anyscale/sa-sandbox-terraform/issues
[badge-build]: https://github.com/anyscale/sa-sandbox-terraform/workflows/CI/CD%20Pipeline/badge.svg
[badge-terraform]: https://img.shields.io/badge/terraform-1.x%20-623CE4.svg?logo=terraform
[badge-tf-aws]: https://img.shields.io/badge/AWS-4.+-F8991D.svg?logo=terraform
[build-status]: https://github.com/anyscale/sa-sandbox-terraform/actions
