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
To support this, sub-modules were created to allow easier long-term management of the resources. These include:
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
* Anyscale v1
  * Build everything - this mimics the existing cloudformation script, but in Terraform.
  * Pass in an existing VPC and Subnets - build everything else.
* Anyscale v2
  * Build everything - this mimics the existing cloudformation script
  * Build everything - use a common name for all resources
  * Pass in an existing VPC and Subnets - build everything else
  * Build everything, but only provide Anyscale access to private subnets that are behind a NAT GW

Additional examples can be requested via an [issues] ticket.

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
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | 3.4.3 |

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

| Name | Type |
|------|------|
| [random_id.common_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_anyscale_access_role_description"></a> [anyscale\_access\_role\_description](#input\_anyscale\_access\_role\_description) | (Optional)<br>The IAM role description for the Anysclae IAM access role.<br>This role is used for cross account access from the Anyscale Controlplane to an AWS account and allows access to manage AWS resources.<br>Default is `Anyscale access role` | `string` | `"Anyscale access role"` | no |
| <a name="input_anyscale_access_steadystate_policy_description"></a> [anyscale\_access\_steadystate\_policy\_description](#input\_anyscale\_access\_steadystate\_policy\_description) | (Optional)<br>Anyscale steady state IAM policy description.<br>Default is `Anyscale Steady State IAM Policy which is used by the Anyscale IAM Access Role` | `string` | `"Anyscale Steady State IAM Policy which is used by the Anyscale IAM Access Role"` | no |
| <a name="input_anyscale_access_steadystate_policy_name"></a> [anyscale\_access\_steadystate\_policy\_name](#input\_anyscale\_access\_steadystate\_policy\_name) | (Optional)<br>Name for the Anyscale default steady state IAM policy.<br>If left `null`, will default to `anyscale_access_steadystate_policy_prefix`<br>If provided, overrides the `anyscale_access_steadystate_policy_prefix` variable.<br>Default is `null`. | `string` | `null` | no |
| <a name="input_anyscale_access_steadystate_policy_prefix"></a> [anyscale\_access\_steadystate\_policy\_prefix](#input\_anyscale\_access\_steadystate\_policy\_prefix) | (Optional)<br>Name prefix for the Anyscale default steady state IAM policy.<br>If `anyscale_access_steadystate_policy_name` is provided, it will override this variable.<br>The variable `general_prefix` is a fall-back prefix if this is not provided.<br>Default is `null` but is set to `anyscale-steady_state-` in a local variable. | `string` | `null` | no |
| <a name="input_anyscale_accessrole_custom_policy"></a> [anyscale\_accessrole\_custom\_policy](#input\_anyscale\_accessrole\_custom\_policy) | (Optional)<br>Anyscale custom IAM policy.<br>This policy will be applied in addition to the default policies added to the Anyscale Access IAM Role.<br>Note: Any customizations to the IAM Role need to be carefully tested and Anyscale is not<br>responsible for any problems that may occur due to misconfiguring the policy and/or Anyscale Access Role.<br>Must be a valid IAM policy.<br>Default is `null`. | `string` | `null` | no |
| <a name="input_anyscale_accessrole_custom_policy_description"></a> [anyscale\_accessrole\_custom\_policy\_description](#input\_anyscale\_accessrole\_custom\_policy\_description) | (Optional)<br>Anyscale IAM custom policy description.<br>Default is `Anyscale custom IAM policy`. | `string` | `"Anyscale custom IAM policy"` | no |
| <a name="input_anyscale_accessrole_custom_policy_name"></a> [anyscale\_accessrole\_custom\_policy\_name](#input\_anyscale\_accessrole\_custom\_policy\_name) | (Optional)<br>Name for an Anyscale custom IAM policy.<br>If left `null`, will default to `anyscale_custom_policy_name_prefix`.<br>Default is `null`. | `string` | `null` | no |
| <a name="input_anyscale_accessrole_custom_policy_name_prefix"></a> [anyscale\_accessrole\_custom\_policy\_name\_prefix](#input\_anyscale\_accessrole\_custom\_policy\_name\_prefix) | (Optional)<br>Name prefix for the Anyscale custom IAM policy.<br>If `anyscale_accessrole_custom_policy_name` is provided, it will override this variable.<br>The variable `general_prefix` is a fall-back prefix if this is not provided.<br>Default is `null` but is set to `anyscale-crossacct-custom-policy-` in a local variable. | `string` | `null` | no |
| <a name="input_anyscale_cloud_id"></a> [anyscale\_cloud\_id](#input\_anyscale\_cloud\_id) | (Optional) Anyscale Cloud ID. Default is `null`. | `string` | `null` | no |
| <a name="input_anyscale_cluster_node_custom_policy"></a> [anyscale\_cluster\_node\_custom\_policy](#input\_anyscale\_cluster\_node\_custom\_policy) | (Optional)<br>Anyscale cluster node custom IAM policy.<br>This policy will be applied in addition to the default policies added to the Cluster Node Role.<br>Note: Any customizations to the IAM Role need to be carefully tested and Anyscale is not<br>responsible for any problems that may occur due to misconfiguring the policy and/or Cluster Role.<br>Must be a valid IAM policy.<br>Default is `null`. | `string` | `null` | no |
| <a name="input_anyscale_cluster_node_custom_policy_description"></a> [anyscale\_cluster\_node\_custom\_policy\_description](#input\_anyscale\_cluster\_node\_custom\_policy\_description) | (Optional)<br>Anyscale IAM cluster node custom policy description.<br>Default is `Anyscale cluster node custom IAM policy`. | `string` | `"Anyscale cluster node custom IAM policy"` | no |
| <a name="input_anyscale_cluster_node_custom_policy_name"></a> [anyscale\_cluster\_node\_custom\_policy\_name](#input\_anyscale\_cluster\_node\_custom\_policy\_name) | (Optional)<br>Name for the Anyscale cluster node custom IAM policy.<br>If left `null`, will default to `anyscale_cluster_node_custom_policy_prefix`.<br>Default is `null`. | `string` | `null` | no |
| <a name="input_anyscale_cluster_node_custom_policy_prefix"></a> [anyscale\_cluster\_node\_custom\_policy\_prefix](#input\_anyscale\_cluster\_node\_custom\_policy\_prefix) | (Optional)<br>Name prefix for the Anyscale cluster node custom IAM policy.<br>If `anyscale_cluster_node_custom_policy_name` is provided, it will override this variable.<br>The variable `general_prefix` is a fall-back prefix if this is not provided.<br>Default is `null` but is set to `anyscale-clusternode-custom-policy-` in a local variable. | `string` | `null` | no |
| <a name="input_anyscale_cluster_node_role_description"></a> [anyscale\_cluster\_node\_role\_description](#input\_anyscale\_cluster\_node\_role\_description) | (Optional)<br>The IAM Role description for the Anyscale Cluster Node Role.<br>This role is used by compute resources to access resources within an AWS account.<br>Default is `Anyscale cluster node role`. | `string` | `"Anyscale cluster node role"` | no |
| <a name="input_anyscale_custom_s3_policy"></a> [anyscale\_custom\_s3\_policy](#input\_anyscale\_custom\_s3\_policy) | (Optional)<br>A valid bucket policy in JSON. This will be an additional S3 bucket policy to the required Anyscale policy.<br>For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide.<br>And for more additional examples, please look at the s3-policy sub-module examples folder.<br>Default is `null`. | `string` | `null` | no |
| <a name="input_anyscale_deploy_env"></a> [anyscale\_deploy\_env](#input\_anyscale\_deploy\_env) | (Required) Anyscale deploy environment. Used in resource names and tags. | `string` | n/a | yes |
| <a name="input_anyscale_efs_name"></a> [anyscale\_efs\_name](#input\_anyscale\_efs\_name) | (Optional) Elastic file system name. Will default to `efs_anyscale` if this var `null` and anyscale\_cloud\_id is also `null`.<br>Default is `null`. | `string` | `null` | no |
| <a name="input_anyscale_efs_tags"></a> [anyscale\_efs\_tags](#input\_anyscale\_efs\_tags) | (Optional)<br>A map of tags for EFS resources.<br>Duplicate tags found in the "tags" variable will get duplicated on the resource.<br>ex:<pre>anyscale_iam_tags = {<br>  "purpose" : "storage",<br>  "criticality" : "critical"<br>}</pre>Default is an empty map. | `map(string)` | `{}` | no |
| <a name="input_anyscale_gateway_vpc_endpoints"></a> [anyscale\_gateway\_vpc\_endpoints](#input\_anyscale\_gateway\_vpc\_endpoints) | A map of Gateway VPC Endpoints to provision into the VPC. This is a map of objects with the following attributes:<br>- `name`: Short service name (either "s3" or "dynamodb")<br>- `policy` = A policy (as JSON string) to attach to the endpoint that controls access to the service. May be `null` for full access.<br>See the submodule variable for a full example.<br>It is Anyscale's recommendation to have an S3 VPC Endpoint to minimize S3 costs and maximize S3 performance.<br>Set to an empty map `{}` to skip creating VPC Endpoints.<br>Default is S3 with an empty (full access) policy. | <pre>map(object({<br>    name   = string<br>    policy = string<br>  }))</pre> | <pre>{<br>  "s3": {<br>    "name": "s3",<br>    "policy": null<br>  }<br>}</pre> | no |
| <a name="input_anyscale_iam_access_role_name"></a> [anyscale\_iam\_access\_role\_name](#input\_anyscale\_iam\_access\_role\_name) | (Optional, forces creation of new resource)<br>The name of the Anyscale IAM access role.<br>If left `null`, will default to anyscale\_iam\_access\_role\_name\_prefix.<br>If provided, overrides the anyscale\_iam\_access\_role\_name\_prefix variable.<br>Default is `null`. | `string` | `null` | no |
| <a name="input_anyscale_iam_access_role_name_prefix"></a> [anyscale\_iam\_access\_role\_name\_prefix](#input\_anyscale\_iam\_access\_role\_name\_prefix) | (Optional, forces creation of new resource)<br>The prefix for the Anyscale IAM access role.<br>If `anyscale_iam_access_role_name_prefix` is provided, it will override this variable.<br>The variable `general_prefix` is a fall-back prefix if this is not provided.<br>Default is `null` but is set to `anyscale-iam-role-` in a local variable. | `string` | `null` | no |
| <a name="input_anyscale_iam_cluster_node_role_name"></a> [anyscale\_iam\_cluster\_node\_role\_name](#input\_anyscale\_iam\_cluster\_node\_role\_name) | (Optional, forces creation of new resource)<br>The name of the Anyscale IAM cluster node role.<br>If left `null`, will default to anyscale\_iam\_access\_role\_name\_prefix.<br>Default is `null`. | `string` | `null` | no |
| <a name="input_anyscale_iam_cluster_node_role_name_prefix"></a> [anyscale\_iam\_cluster\_node\_role\_name\_prefix](#input\_anyscale\_iam\_cluster\_node\_role\_name\_prefix) | (Optional, forces creation of new resource)<br>The prefix of the Anyscale Cluster Node IAM role.<br>If `anyscale_iam_cluster_node_role_name` is provided, it will override this variable.<br>The variable `general_prefix` is a fall-back prefix if this is not provided.<br>Default is `null` but is set to `anyscale-cluster-node-` in a local variable. | `string` | `null` | no |
| <a name="input_anyscale_iam_s3_policy_description"></a> [anyscale\_iam\_s3\_policy\_description](#input\_anyscale\_iam\_s3\_policy\_description) | (Optional)<br>Anyscale S3 access IAM policy description.<br>Default is `Anyscale S3 Access IAM Policy`. | `string` | `"Anyscale S3 Access IAM Policy"` | no |
| <a name="input_anyscale_iam_s3_policy_name"></a> [anyscale\_iam\_s3\_policy\_name](#input\_anyscale\_iam\_s3\_policy\_name) | (Optional)<br>Name for the Anyscale S3 access IAM policy.<br>If left `null`, will default to `anyscale_iam_s3_policy_name_prefix`.<br>Default is `null`. | `string` | `null` | no |
| <a name="input_anyscale_iam_s3_policy_name_prefix"></a> [anyscale\_iam\_s3\_policy\_name\_prefix](#input\_anyscale\_iam\_s3\_policy\_name\_prefix) | (Optional)<br>Name prefix for the Anyscale S3 access IAM policy.<br>If `anyscale_iam_s3_policy_name` is provided, it will override this variable.<br>The variable `general_prefix` is a fall-back prefix if this is not provided.<br>Default is `null` but is set to `anyscale-iam-s3-` in a local variable. | `string` | `null` | no |
| <a name="input_anyscale_iam_tags"></a> [anyscale\_iam\_tags](#input\_anyscale\_iam\_tags) | (Optional)<br>A map of tags for IAM resources.<br>Duplicate tags found in the "tags" variable will get duplicated on the resource.<br>ex:<pre>anyscale_iam_tags = {<br>  "purpose" : "iam",<br>  "criticality" : "critical"<br>}</pre>Default is an empty map. | `map(string)` | `{}` | no |
| <a name="input_anyscale_s3_bucket_name"></a> [anyscale\_s3\_bucket\_name](#input\_anyscale\_s3\_bucket\_name) | (Optional - forces new resource)<br>The name of the bucket used to store Anyscale related logs and other shared resources.<br>If left `null`, will default to anyscale\_s3\_bucket\_prefix.<br>If provided, overrides the anyscale\_s3\_bucket\_prefix variable.<br>Conflicts with anyscale\_bucket\_prefix. Default is `null`. | `string` | `null` | no |
| <a name="input_anyscale_s3_bucket_prefix"></a> [anyscale\_s3\_bucket\_prefix](#input\_anyscale\_s3\_bucket\_prefix) | (Optional - forces new resource)<br>Creates a unique bucket name beginning with the specified prefix.<br>If `anyscale_s3_bucket_name` is provided, it will override this variable.<br>The variable `general_prefix` is a fall-back prefix if this is not provided.<br>Default is `null` but is set to `anyscale-` in a local variable. | `string` | `null` | no |
| <a name="input_anyscale_s3_force_destroy"></a> [anyscale\_s3\_force\_destroy](#input\_anyscale\_s3\_force\_destroy) | (Optional)<br>Set to true to delete all objects from the bucket so that the bucket can be destroyed without error.<br>If set to true and bucket is destroyed, objects are not recoverable.<br>Default is `false`.<br>Note: With this default, you need to empty the bucket if there are objects before `terraform destroy` can be completed succesfully. | `bool` | `false` | no |
| <a name="input_anyscale_s3_lifecycle_rule"></a> [anyscale\_s3\_lifecycle\_rule](#input\_anyscale\_s3\_lifecycle\_rule) | (Optional)<br>List of maps containing configuration of object lifecycle management.<br>ex:<pre>anyscale_s3_lifecycle_rule = [<br>  {<br>    id      = "log"<br>    enabled = true<br>    filter = {<br>      prefix = "log1/"<br>    }<br>    transition = [<br>      {<br>        days          = 30<br>        storage_class = "ONEZONE_IA"<br>      }, {<br>        days          = 60<br>        storage_class = "GLACIER"<br>      }<br>    ]<br>    noncurrent_version_transition = [<br>      {<br>        days          = 30<br>        storage_class = "STANDARD_IA"<br>      },<br>    ]<br>  }<br>]</pre>Default is an empty list. | `any` | `[]` | no |
| <a name="input_anyscale_s3_server_side_encryption"></a> [anyscale\_s3\_server\_side\_encryption](#input\_anyscale\_s3\_server\_side\_encryption) | (Optional)<br>Configuration to enforce server side encryption (KMS or AES256).<br>If you are using KMS, you must proivde the KMS Key ID.<br>ex using kms:<pre>apply_server_side_encryption_by_default = {<br>  kms_master_key_id = "1234abcd-12ab-34cd-56ef-1234567890ab"<br>  sse_algorithm     = "aws:kms"<br>}</pre>Default is `{ sse_algorithm = "AES256" }` | `map(string)` | <pre>{<br>  "sse_algorithm": "AES256"<br>}</pre> | no |
| <a name="input_anyscale_s3_tags"></a> [anyscale\_s3\_tags](#input\_anyscale\_s3\_tags) | (Optional)<br>A map of tags for S3 resources.<br>Duplicate tags found in the "tags" variable will get duplicated on the resource.<br>ex:<pre>anyscale_iam_tags = {<br>  "purpose" : "storage",<br>  "criticality" : "critical"<br>}</pre>Default is an empty map. | `map(string)` | `{}` | no |
| <a name="input_anyscale_securitygroup_tags"></a> [anyscale\_securitygroup\_tags](#input\_anyscale\_securitygroup\_tags) | (Optional)<br>A map of tags for Security Group resources.<br>Duplicate tags found in the "tags" variable will get duplicated on the resource.<br>ex:<pre>anyscale_iam_tags = {<br>  "purpose" : "security",<br>  "criticality" : "critical"<br>}</pre>Default is an empty map. | `map(string)` | `{}` | no |
| <a name="input_anyscale_vpc_cidr_block"></a> [anyscale\_vpc\_cidr\_block](#input\_anyscale\_vpc\_cidr\_block) | (Optional) The IPv4 CIDR block for the VPC. CIDR can be explicitly set or it can be derived from IPAM using `ipv4_netmask_length` & `ipv4_ipam_pool_id`. Default is `10.0.0.0/16` | `string` | `"10.0.0.0/16"` | no |
| <a name="input_anyscale_vpc_name"></a> [anyscale\_vpc\_name](#input\_anyscale\_vpc\_name) | (Optional) VPC name. Will default to `vpc_<anyscale_cloud_id>`. | `string` | `null` | no |
| <a name="input_anyscale_vpc_private_subnets"></a> [anyscale\_vpc\_private\_subnets](#input\_anyscale\_vpc\_private\_subnets) | (Optional) A list of private subnets inside the VPC. Default is an empty list. | `list(string)` | `[]` | no |
| <a name="input_anyscale_vpc_public_subnets"></a> [anyscale\_vpc\_public\_subnets](#input\_anyscale\_vpc\_public\_subnets) | (Optional) A list of public subnets inside the VPC. Default is an empty list. | `list(string)` | `[]` | no |
| <a name="input_anyscale_vpc_tags"></a> [anyscale\_vpc\_tags](#input\_anyscale\_vpc\_tags) | (Optional)<br>A map of tags for VPC resources.<br>Duplicate tags found in the "tags" variable will get duplicated on the resource.<br>ex:<pre>anyscale_vpc_tags = {<br>  "purpose" : "networking",<br>  "criticality" : "critical"<br>}</pre>Default is an empty map. | `map(string)` | `{}` | no |
| <a name="input_common_prefix"></a> [common\_prefix](#input\_common\_prefix) | (Optional)<br>A common prefix to add to resources created (where prefixes are allowed).<br>If paired with `use_common_name`, this will apply to all resources.<br>If this is not paired with `use_common_name`, this applies to:<br>  - S3 Buckets<br>  - IAM Resources<br>  - Security Groups<br>Resource specific prefixes override this variable.<br>Max length is 30 characters.<br>Default is `null` | `string` | `null` | no |
| <a name="input_efs_creation_token"></a> [efs\_creation\_token](#input\_efs\_creation\_token) | (Optional) A unique token used as reference when creating the Elastic File System to ensure idempotent file system creation.<br>Default is `null` which forces Terraform to generate it. | `string` | `null` | no |
| <a name="input_efs_lifecycle_transition_to_ia"></a> [efs\_lifecycle\_transition\_to\_ia](#input\_efs\_lifecycle\_transition\_to\_ia) | (Optional) Indicates how long it takes to transition files to Infrequent Access storage class.<br>No value, or an empty list, means never.<br>Must either be an empty list or one of "AFTER\_7\_DAYS", "AFTER\_14\_DAYS", "AFTER\_30\_DAYS", "AFTER\_60\_DAYS", "AFTER\_90\_DAYS".<br>Default is `AFTER_60_DAYS` which will transition to IA after 60 days. | `list(string)` | <pre>[<br>  "AFTER_60_DAYS"<br>]</pre> | no |
| <a name="input_efs_lifecycle_transition_to_primary_storage_class"></a> [efs\_lifecycle\_transition\_to\_primary\_storage\_class](#input\_efs\_lifecycle\_transition\_to\_primary\_storage\_class) | (Optional) Indicates the policy used to transition a file from Infrequent Access (IA) storage to primary storage.<br>Must either be an empty list or `AFTER_1_ACCESS`.<br>Default is `AFTER_1_ACCESS`. | `list(string)` | <pre>[<br>  "AFTER_1_ACCESS"<br>]</pre> | no |
| <a name="input_existing_s3_bucket_arn"></a> [existing\_s3\_bucket\_arn](#input\_existing\_s3\_bucket\_arn) | (Optional)<br>The name of an existing S3 bucket that you'd like to use.<br>Please make sure that it meets the minimum requirements for Anyscale including:<br>  - Bucket Policy<br>  - CORS Policy<br>  - Encryption configuration<br>Default is `null` | `string` | `null` | no |
| <a name="input_existing_vpc_id"></a> [existing\_vpc\_id](#input\_existing\_vpc\_id) | (Optional) An existing VPC ID. If provided, this will skip creating resources with the Anyscale VPC module. Subnet IDs is also required if this is provided. Default is `null`. | `string` | `null` | no |
| <a name="input_existing_vpc_private_route_table_ids"></a> [existing\_vpc\_private\_route\_table\_ids](#input\_existing\_vpc\_private\_route\_table\_ids) | (Optional)<br>Existing VPC Private Route Table IDs.<br>If provided, this will map new private subnets to these route table IDs.<br>If no new subnets are created, these route tables will be used to create VPC Endpoint(s). | `list(string)` | `[]` | no |
| <a name="input_existing_vpc_public_route_table_ids"></a> [existing\_vpc\_public\_route\_table\_ids](#input\_existing\_vpc\_public\_route\_table\_ids) | (Optional)<br>Existing VPC Public Route Table IDs.<br>If provided, these route tables will be used to create VPC Endpoint(s). | `list(string)` | `[]` | no |
| <a name="input_existing_vpc_subnet_ids"></a> [existing\_vpc\_subnet\_ids](#input\_existing\_vpc\_subnet\_ids) | (Optional) Existing subnet IDs to create Anyscale resources in. If provided, this will skip creating resources with the Anyscale VPC module. VPC ID is also required is this is provided. Default is an empty list. | `list(string)` | `[]` | no |
| <a name="input_random_name_suffix_length"></a> [random\_name\_suffix\_length](#input\_random\_name\_suffix\_length) | (Optional)<br>Determines the random suffix length that is used to generate a common name.<br>Certain AWS resources have a hard limit on name lengths and this will allow<br>the ability to control how many characters are added as a suffix.<br>Must be >= 2 and <= 30.<br>Default is `6` | `number` | `6` | no |
| <a name="input_security_group_create_anyscale_public_ingress"></a> [security\_group\_create\_anyscale\_public\_ingress](#input\_security\_group\_create\_anyscale\_public\_ingress) | (Optional) Determines if public ingress rules should be created. Default is `false`. | `bool` | `false` | no |
| <a name="input_security_group_ingress_allow_access_from_cidr_range"></a> [security\_group\_ingress\_allow\_access\_from\_cidr\_range](#input\_security\_group\_ingress\_allow\_access\_from\_cidr\_range) | (Required) Comma delimited string of IPv4 CIDR range to allow access to anyscale resources.<br>This should be the list of CIDR ranges that have access to the clusters. If using Anyscale v1,<br>this should be public IPs. If using Anyscale v2, public or private IPs are supported. SSH and HTTPs<br>ports will be opened to these CIDR ranges.<br>ex: "10.0.1.0/24,24.1.24.24/32" | `string` | n/a | yes |
| <a name="input_security_group_ingress_with_existing_security_groups_map"></a> [security\_group\_ingress\_with\_existing\_security\_groups\_map](#input\_security\_group\_ingress\_with\_existing\_security\_groups\_map) | (Optional) List of security groups and rules to allow ingress from. Default is an empty list. | `list(map(string))` | `[]` | no |
| <a name="input_security_group_name"></a> [security\_group\_name](#input\_security\_group\_name) | (Optional) The name for the security group. If provided, overrides the security\_group\_name\_prefix.<br>Default is `null`. | `string` | `null` | no |
| <a name="input_security_group_name_prefix"></a> [security\_group\_name\_prefix](#input\_security\_group\_name\_prefix) | (Optional)<br>The name prefix for the security group.<br>If `security_group_name` is provided, it will override this variable.<br>The variable `general_prefix` is a fall-back prefix if this is not provided.<br><br>Default is `null` but is set to `anyscale-security-group-` in a local variable. | `string` | `null` | no |
| <a name="input_security_group_override_ingress_from_cidr_map"></a> [security\_group\_override\_ingress\_from\_cidr\_map](#input\_security\_group\_override\_ingress\_from\_cidr\_map) | (Optional) List of ingress rules to create with cidr ranges.<br>If this variable is provided/populated, the default rules will not be created. At a minimum, https and ssh need<br>to be allowed from a IPv4 CIDR block that allows access for the users who are using Anyscale.<br>Default is an empty list. | `list(map(string))` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional)<br>A map of default tags to be added to all resources that accept tags.<br>Resource dependent tags will be appended to this list.<br>ex:<pre>tags = {<br>  application = "Anyscale",<br>  environment = "prod"<br>}</pre>Default is an empty map. | `map(string)` | `{}` | no |
| <a name="input_use_common_name"></a> [use\_common\_name](#input\_use\_common\_name) | (Optional)<br>Determines if a standard name should be used across all resources.<br>If set to true and `common_prefix` is also provided, the `common_prefix` will be used prefixed to a common name.<br>If set to true and `common_prefix` is not provided, the prefix will be `anyscale-`<br>If set to true, this will also use a random suffix to avoid name collisions.<br>Default is `false` | `bool` | `false` | no |

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
[Issues]: https://github.com/anyscale/terraform-aws-anyscale-cloudfoundation-modules/issues
[badge-build]: https://github.com/anyscale/terraform-aws-anyscale-cloudfoundation-modules/workflows/CI/CD%20Pipeline/badge.svg
[badge-terraform]: https://img.shields.io/badge/terraform-1.x%20-623CE4.svg?logo=terraform
[badge-tf-aws]: https://img.shields.io/badge/AWS-4.+-F8991D.svg?logo=terraform
[build-status]: https://github.com/anyscale/terraform-aws-anyscale-cloudfoundation-modules/actions
