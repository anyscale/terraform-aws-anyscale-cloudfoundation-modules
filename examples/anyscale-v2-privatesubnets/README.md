# Anyscale Networking Stack v2 - Private Subnets

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
| <a name="module_aws_anyscale_v2_private_vpc"></a> [aws\_anyscale\_v2\_private\_vpc](#module\_aws\_anyscale\_v2\_private\_vpc) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_anyscale_cloud_id"></a> [anyscale\_cloud\_id](#input\_anyscale\_cloud\_id) | (Optional) Anyscale Cloud ID. Default is `null`. | `string` | `null` | no |
| <a name="input_anyscale_deploy_env"></a> [anyscale\_deploy\_env](#input\_anyscale\_deploy\_env) | (Required) Anyscale deploy environment. Used in resource names and tags. | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region in which all resources will be created. | `string` | n/a | yes |
| <a name="input_s3_tag_value"></a> [s3\_tag\_value](#input\_s3\_tag\_value) | This is used to set the S3 tag value for testing purposes | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to all resources that accept tags. | `map(string)` | <pre>{<br>  "environment": "test",<br>  "test": true<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_anyscale_v2_efs_id"></a> [anyscale\_v2\_efs\_id](#output\_anyscale\_v2\_efs\_id) | Anyscale Elastic File System ID. |
| <a name="output_anyscale_v2_iam_instance_role_arn"></a> [anyscale\_v2\_iam\_instance\_role\_arn](#output\_anyscale\_v2\_iam\_instance\_role\_arn) | Anyscale IAM instance role arn. |
| <a name="output_anyscale_v2_iam_role_arn"></a> [anyscale\_v2\_iam\_role\_arn](#output\_anyscale\_v2\_iam\_role\_arn) | Anyscale IAM access role arn. |
| <a name="output_anyscale_v2_private_subnet_ids"></a> [anyscale\_v2\_private\_subnet\_ids](#output\_anyscale\_v2\_private\_subnet\_ids) | Anyscale VPC Private Subnet IDs. If there were none created, return an empty string. |
| <a name="output_anyscale_v2_public_subnet_ids"></a> [anyscale\_v2\_public\_subnet\_ids](#output\_anyscale\_v2\_public\_subnet\_ids) | Anyscale VPC Public Subnet IDs. If there were none created, return an empty string. |
| <a name="output_anyscale_v2_s3_bucket_id"></a> [anyscale\_v2\_s3\_bucket\_id](#output\_anyscale\_v2\_s3\_bucket\_id) | Anyscale S3 Bucket ID. If a bucket was not created, return an empty string. |
| <a name="output_anyscale_v2_security_group_id"></a> [anyscale\_v2\_security\_group\_id](#output\_anyscale\_v2\_security\_group\_id) | Anyscale Security Group ID. If a security group was not created, return an empty string. |
| <a name="output_anyscale_v2_vpc_id"></a> [anyscale\_v2\_vpc\_id](#output\_anyscale\_v2\_vpc\_id) | Anyscale VPC ID. If there was not one created, return the one that was used during other resource creation. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
