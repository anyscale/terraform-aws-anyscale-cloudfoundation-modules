# Anyscale Networking Stack v2 - KMS Encryption for S3 and EFS

This **example** will build the resources necessary to run Anyscale in an AWS account. This example will create a
[Direct Networking](https://docs.anyscale.com/cloud-deployment/aws/manage-clouds#anyscale-clouds-on-aws) solution.

In this example, the EFS and S3 will use a shared KMS Key; however, each could be unique.

## To execute
A general understanding of Terraform and AWS is helpful for understanding how to execute this Terraform. For a high-level overview of both,
please see the [Getting Started guide](https://github.com/anyscale/terraform-aws-anyscale-cloudfoundation-modules/blob/main/getting-started.md).

## Using with the Anyscale CLI

The outputs from this Terraform can be used to build an anyscale cloud with the anyscale CLI. To use:
1. Make sure you have the latest Anyscale CLI installed `pip install anyscale --upgrade`
2. The terraform output: `anyscale_register_command` will provide an example of an Anyscale CLI command you can use to register an Anyscale Cloud. You must change the value: `<CUSTOMER_DEFINED_NAME>` to a cloud name you would like to use.

Example:

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
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.41.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_anyscale_v2_kms"></a> [aws\_anyscale\_v2\_kms](#module\_aws\_anyscale\_v2\_kms) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_kms_key.anyscale_v2_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.anyscale_v2_kms_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region in which all resources will be created.<br>ex:<pre>aws_region = "us-east-2"</pre> | `string` | n/a | yes |
| <a name="input_customer_ingress_cidr_ranges"></a> [customer\_ingress\_cidr\_ranges](#input\_customer\_ingress\_cidr\_ranges) | The IPv4 CIDR block that is allowed to access the clusters.<br>This provides the ability to lock down the v1 stack to just the public IPs of a corporate network.<br>This is added to the security group and allows port 443 (https) and 22 (ssh) access.<br><br>While not recommended, you can set this to `0.0.0.0/0` to allow access from anywhere.<br>ex:<pre>customer_ingress_cidr_ranges = "52.1.1.23/32,10.1.0.0/16"</pre> | `string` | n/a | yes |
| <a name="input_key_admin_role_name"></a> [key\_admin\_role\_name](#input\_key\_admin\_role\_name) | (Required)<br>The name of the IAM Role that should have permissions to manage the KMS key created.<br><br>ex:<pre>key_admin_role_name = "anyscale-key-admin-role"</pre> | `string` | n/a | yes |
| <a name="input_anyscale_cloud_id"></a> [anyscale\_cloud\_id](#input\_anyscale\_cloud\_id) | (Optional) Anyscale Cloud ID.<br>This is used to lock down the cross account access role by Cloud ID. Because the Cloud ID is unique to each<br>customer, this ensures that only the customer can access their own resources. The Cloud ID is not known until the<br>Cloud is created, so this is an optional variable.<br>ex:<pre>anyscale_cloud_id = "cld_abcdefghijklmnop1234567890"</pre> | `string` | `null` | no |
| <a name="input_anyscale_deploy_env"></a> [anyscale\_deploy\_env](#input\_anyscale\_deploy\_env) | (Optional) Anyscale deployment environment. Used in resource names and tags.<br>ex:<pre>anyscale_deploy_env = "production"</pre> | `string` | `"production"` | no |
| <a name="input_anyscale_org_id"></a> [anyscale\_org\_id](#input\_anyscale\_org\_id) | (Optional) Anyscale Organization ID.<br><br>This is used to lock down the cross account access role by Organization ID. Because the Organization ID is unique to each<br>customer, this ensures that only the customer can access their own resources.<br><br>ex:<pre>anyscale_org_id = "org_abcdefghijklmn1234567890"</pre> | `string` | `null` | no |
| <a name="input_common_prefix"></a> [common\_prefix](#input\_common\_prefix) | (Optional)<br>Default for this EXAMPLE is `anyscale-pfx-test-` | `string` | `"anyscale-pfx-test-"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags.<br>These tags will be added to all cloud resources that accept tags.<br>ex:<pre>tags = {<br>  "environment" = "test",<br>  "team" = "anyscale"<br>}</pre> | `map(string)` | <pre>{<br>  "environment": "test",<br>  "test": true<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_anyscale_register_command"></a> [anyscale\_register\_command](#output\_anyscale\_register\_command) | Anyscale register command.<br>This output can be used with the Anyscale CLI to register a new Anyscale Cloud.<br>You will need to replace `<CUSTOMER_DEFINED_NAME>` with a name of your choosing before running the Anyscale CLI command. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
