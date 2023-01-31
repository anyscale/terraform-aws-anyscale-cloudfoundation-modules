# Anyscale Networking Stack v1 - Existing VPC

This builds the resources needed to run an Anyscale v1 stack. It builds everything except the VPC.
VPC ID, Subnet IDs, etc need to be provided.

## Using with Anyscale CLI

The outputs from this Terraform can be used to build an anyscale cloud with the anyscale CLI. To use:
1. Make sure you have the latest Anyscale CLI installed `pip install anyscale --upgrade`
2. Grab the outputs from the CLI to run `anyscale cloud register`

example:

```
anyscale cloud register --provider aws \
  --name <CUSTOMER_DEFINED_NAME> \
  --region <VPC_REGION> \
  --vpc-id <VPC ID FROM Outputs> \
  --subnet-ids <SUBNET_ID1>,<SUBNET_ID2>,<SUBNET_ID3>,<SUBNET_ID4> \
  --efs-id <FILE_SYSTEM_ID> \
  --anyscale-iam-role-id <ANYSCALE_IAM_ROLE_ARN> \
  --instance-iam-role-id <INSTANCE_IAM_ROLE_ARN> \
  --security-group-ids <SECURITY_GROUP_ID> \
  --s3-bucket-id <S3_BUCKET_NAME>

anyscale cloud verify --name <CUSTOMER_DEFINED_NAME>
anyscale cloud delete --name <CUSTOMER_DEFINED_NAME>
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_anyscale_v1_existing_vpc"></a> [aws\_anyscale\_v1\_existing\_vpc](#module\_aws\_anyscale\_v1\_existing\_vpc) | ../.. | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_anyscale_cloud_id"></a> [anyscale\_cloud\_id](#input\_anyscale\_cloud\_id) | (Optional) Anyscale Cloud ID. Default is `null`. | `string` | `null` | no |
| <a name="input_anyscale_deploy_env"></a> [anyscale\_deploy\_env](#input\_anyscale\_deploy\_env) | (Required) Anyscale deploy environment. Used in resource names and tags. | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region in which all resources will be created. | `string` | n/a | yes |
| <a name="input_customer_ingress_cidr_ranges"></a> [customer\_ingress\_cidr\_ranges](#input\_customer\_ingress\_cidr\_ranges) | The IPv4 CIDR block that is allowed to access the clusters.<br>This provides the ability to lock down the v1 stack to just the public IPs of a corporate network.<br>This is added to the security group and allows port 443 (https) and 22 (ssh) access.<br>ex: `52.1.1.23/32,10.1.0.0/16'<br>Default is `0.0.0.0/0`<br>` | `string` | `"0.0.0.0/0"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to all resources that accept tags. | `map(string)` | <pre>{<br>  "environment": "test",<br>  "test": true<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_anyscale_v1_existing_vpc_efs_id"></a> [anyscale\_v1\_existing\_vpc\_efs\_id](#output\_anyscale\_v1\_existing\_vpc\_efs\_id) | Anyscale Elastic File System ID. |
| <a name="output_anyscale_v1_existing_vpc_efs_mount_target_ids"></a> [anyscale\_v1\_existing\_vpc\_efs\_mount\_target\_ids](#output\_anyscale\_v1\_existing\_vpc\_efs\_mount\_target\_ids) | Anyscale Elastic File System mount target IDs. If EFS mount targets were not created, return an empty list. |
| <a name="output_anyscale_v1_existing_vpc_iam_instance_role_arn"></a> [anyscale\_v1\_existing\_vpc\_iam\_instance\_role\_arn](#output\_anyscale\_v1\_existing\_vpc\_iam\_instance\_role\_arn) | Anyscale IAM instance role arn. |
| <a name="output_anyscale_v1_existing_vpc_iam_role_arn"></a> [anyscale\_v1\_existing\_vpc\_iam\_role\_arn](#output\_anyscale\_v1\_existing\_vpc\_iam\_role\_arn) | Anyscale IAM access role arn. |
| <a name="output_anyscale_v1_existing_vpc_s3_bucket_id"></a> [anyscale\_v1\_existing\_vpc\_s3\_bucket\_id](#output\_anyscale\_v1\_existing\_vpc\_s3\_bucket\_id) | Anyscale S3 Bucket ID. If a bucket was not created, return an empty string. |
| <a name="output_anyscale_v1_existing_vpc_security_group_id"></a> [anyscale\_v1\_existing\_vpc\_security\_group\_id](#output\_anyscale\_v1\_existing\_vpc\_security\_group\_id) | Anyscale Security Group ID. If a security group was not created, return an empty string. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
