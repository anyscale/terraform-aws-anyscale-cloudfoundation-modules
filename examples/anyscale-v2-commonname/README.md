# Anyscale Networking Stack v2 - Common Name

This **example** will build the resources necessary to run Anyscale in an AWS account. This example will build a
[Direct Networking](https://docs.anyscale.com/cloud-deployment/aws/manage-clouds#anyscale-clouds-on-aws) solution.
The resources built by this Terraform will all have a common name prefix.

This also adds additional IAM policies to the data plane role.

This will build:
- A VPC Network with an IGW
- Security Groups to be used by EC2 instances
- IAM Roles for the data plane and the control plane
- S3 bucket & bucket policy

## To execute
A general understanding of Terraform and AWS are useful for executing this Terraform. For a high level overview of both,
please see the [getting started guide](https://github.com/anyscale/terraform-aws-anyscale-cloudfoundation-modules/blob/main/getting-started.md).

## Using with Anyscale CLI

The outputs from this Terraform can be used to build an anyscale cloud with the anyscale CLI. To use:
1. Make sure you have the latest Anyscale CLI installed `pip install anyscale --upgrade`
2. The terraform output, `anyscale_register_command` will provide an example Anyscale CLI command that can be used to register an Anyscale Cloud. You will need to change `<CUSTOMER_DEFINED_NAME>` to a cloud name that you would like to use.

example:

```sh
anyscale cloud register --provider aws \
  --name <CUSTOMER_DEFINED_NAME> \
  --region <VPC_REGION> \
  --vpc-id <VPC ID FROM Outputs> \
  --subnet-ids <SUBNET_ID1>,<SUBNET_ID2>,<SUBNET_ID3>,<SUBNET_ID4> \
  --efs-id <FILE_SYSTEM_ID> \
  --anyscale-iam-role-id <ANYSCALE_IAM_ROLE_ARN> \
  --instance-iam-role-id <INSTANCE_IAM_ROLE_ARN> \
  --security-group-ids <SECURITY_GROUP_ID> \
  --s3-bucket-id <S3_BUCKET_NAME> \
  --external-id <EXTERNAL_ID>

anyscale cloud verify --name <CUSTOMER_DEFINED_NAME>
anyscale cloud delete --name <CUSTOMER_DEFINED_NAME>
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_anyscale_v2_common_name"></a> [aws\_anyscale\_v2\_common\_name](#module\_aws\_anyscale\_v2\_common\_name) | ../.. | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_anyscale_external_id"></a> [anyscale\_external\_id](#input\_anyscale\_external\_id) | (Required) A string that will be used for the IAM trust policy.<br/>The trust policy for the control plane IAM role will be locked down to the provided external ID.<br/><br/>If provided, you must also set `anyscale_org_id` which will be prepended to the external ID.<br/><br/>ex:<pre>anyscale_external_id = "external-id-12345"</pre> | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region in which all resources will be created.<br/>ex:<pre>aws_region = "us-east-2"</pre> | `string` | n/a | yes |
| <a name="input_customer_ingress_cidr_ranges"></a> [customer\_ingress\_cidr\_ranges](#input\_customer\_ingress\_cidr\_ranges) | The IPv4 CIDR block that is allowed to access the clusters.<br/>This provides the ability to lock down the v1 stack to just the public IPs of a corporate network.<br/>This is added to the security group and allows port 443 (https) and 22 (ssh) access.<br/><br/>While not recommended, you can set this to `0.0.0.0/0` to allow access from anywhere.<br/>ex:<pre>customer_ingress_cidr_ranges = "52.1.1.23/32,10.1.0.0/16"</pre> | `string` | n/a | yes |
| <a name="input_anyscale_cloud_id"></a> [anyscale\_cloud\_id](#input\_anyscale\_cloud\_id) | (Optional) Anyscale Cloud ID.<br/>This is used to lock down the cross account access role by Cloud ID. Because the Cloud ID is unique to each<br/>customer, this ensures that only the customer can access their own resources. The Cloud ID is not known until the<br/>Cloud is created, so this is an optional variable.<br/>ex:<pre>anyscale_cloud_id = "cld_abcdefghijklmnop1234567890"</pre> | `string` | `null` | no |
| <a name="input_anyscale_deploy_env"></a> [anyscale\_deploy\_env](#input\_anyscale\_deploy\_env) | (Optional) Anyscale deployment environment. Used in resource names and tags.<br/>ex:<pre>anyscale_deploy_env = "production"</pre> | `string` | `"production"` | no |
| <a name="input_anyscale_org_id"></a> [anyscale\_org\_id](#input\_anyscale\_org\_id) | (Optional) Anyscale Organization ID.<br/><br/>This is used to lock down the cross account access role by Organization ID. Because the Organization ID is unique to each<br/>customer, this ensures that only the customer can access their own resources.<br/><br/>ex:<pre>anyscale_org_id = "org_abcdefghijklmn1234567890"</pre> | `string` | `null` | no |
| <a name="input_anyscale_s3_force_destroy"></a> [anyscale\_s3\_force\_destroy](#input\_anyscale\_s3\_force\_destroy) | This is used to set the S3 force destroy value for testing purposes | `bool` | `false` | no |
| <a name="input_common_prefix"></a> [common\_prefix](#input\_common\_prefix) | (Optional)<br/>Default for this EXAMPLE is `anyscale-pfx-test-` | `string` | `"anyscale-pfx-test-"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags.<br/>These tags will be added to all cloud resources that accept tags.<br/>ex:<pre>tags = {<br/>  "environment" = "test",<br/>  "team" = "anyscale"<br/>}</pre> | `map(string)` | <pre>{<br/>  "environment": "test",<br/>  "test": true<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_anyscale_register_command"></a> [anyscale\_register\_command](#output\_anyscale\_register\_command) | Anyscale register command.<br/>This output can be used with the Anyscale CLI to register a new Anyscale Cloud.<br/>You will need to replace `<CUSTOMER_DEFINED_NAME>` with a name of your choosing before running the Anyscale CLI command. |
| <a name="output_anyscale_v2_iam_instance_role_arn"></a> [anyscale\_v2\_iam\_instance\_role\_arn](#output\_anyscale\_v2\_iam\_instance\_role\_arn) | Anyscale IAM instance role arn. |
| <a name="output_anyscale_v2_iam_role_arn"></a> [anyscale\_v2\_iam\_role\_arn](#output\_anyscale\_v2\_iam\_role\_arn) | Anyscale IAM access role arn. |
| <a name="output_anyscale_v2_private_routetable_ids"></a> [anyscale\_v2\_private\_routetable\_ids](#output\_anyscale\_v2\_private\_routetable\_ids) | Anyscale VPC Private Route Table IDs. If none were created, return an empty string. |
| <a name="output_anyscale_v2_private_subnet_ids"></a> [anyscale\_v2\_private\_subnet\_ids](#output\_anyscale\_v2\_private\_subnet\_ids) | Anyscale VPC Private Subnet IDs. If there were none created, return an empty string. |
| <a name="output_anyscale_v2_public_routetable_ids"></a> [anyscale\_v2\_public\_routetable\_ids](#output\_anyscale\_v2\_public\_routetable\_ids) | Anyscale VPC Public Route Table IDs. If none were created, return an empty string. |
| <a name="output_anyscale_v2_public_subnet_ids"></a> [anyscale\_v2\_public\_subnet\_ids](#output\_anyscale\_v2\_public\_subnet\_ids) | Anyscale VPC Public Subnet IDs. If there were none created, return an empty string. |
| <a name="output_anyscale_v2_s3_bucket_id"></a> [anyscale\_v2\_s3\_bucket\_id](#output\_anyscale\_v2\_s3\_bucket\_id) | Anyscale S3 Bucket ID. If a bucket was not created, return an empty string. |
| <a name="output_anyscale_v2_security_group_id"></a> [anyscale\_v2\_security\_group\_id](#output\_anyscale\_v2\_security\_group\_id) | Anyscale Security Group ID. If a security group was not created, return an empty string. |
| <a name="output_anyscale_v2_vpc_id"></a> [anyscale\_v2\_vpc\_id](#output\_anyscale\_v2\_vpc\_id) | Anyscale VPC ID. If there was not one created, return the one that was used during other resource creation. |
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
