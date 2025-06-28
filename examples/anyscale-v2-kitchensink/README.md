# Anyscale v2 - Kitchen Sink

This **example** will build the resources necessary to run Anyscale in an AWS account. This example will build a
[Private Networking](https://docs.anyscale.com/cloud-deployment/aws/manage-clouds#anyscale-clouds-on-aws) solution.
The resources built by this Terraform will all have a common name prefix.

This also adds additional IAM policies to the Cluster role and utilizes as many parameters as possible that don't conflict with one another.

## To execute
A general understanding of Terraform and AWS are useful for executing this Terraform. For a high level overview of both,
please see the [getting started guide](https://github.com/anyscale/terraform-aws-anyscale-cloudfoundation-modules/blob/main/getting-started.md).

## Using with Anyscale CLI

The outputs from this Terraform can be used to build an anyscale cloud with the anyscale CLI. To use:
1. Make sure you have the latest Anyscale CLI installed `pip install anyscale --upgrade`
2. The terraform output, `anyscale_register_command` will provide an example Anyscale CLI command that can be used to register an Anyscale Cloud. You will need to change `<CUSTOMER_DEFINED_NAME>` to a cloud name that you would like to use.

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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.16.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.16.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_anyscale_v2_kitchen_sink"></a> [aws\_anyscale\_v2\_kitchen\_sink](#module\_aws\_anyscale\_v2\_kitchen\_sink) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy_document.custom_s3_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | (Required) The AWS region in which all resources will be created.<br/><br/>ex:<pre>aws_region = "us-east-2"</pre> | `string` | n/a | yes |
| <a name="input_customer_ingress_cidr_ranges"></a> [customer\_ingress\_cidr\_ranges](#input\_customer\_ingress\_cidr\_ranges) | The IPv4 CIDR block that is allowed to access the clusters.<br/>This provides the ability to lock down the v1 stack to just the public IPs of a corporate network.<br/>This is added to the security group and allows port 443 (https) and 22 (ssh) access.<br/><br/>While not recommended, you can set this to `0.0.0.0/0` to allow access from anywhere.<br/><br/>ex:<pre>customer_ingress_cidr_ranges = "52.1.1.23/32,10.1.0.0/16"</pre> | `string` | n/a | yes |
| <a name="input_anyscale_cloud_id"></a> [anyscale\_cloud\_id](#input\_anyscale\_cloud\_id) | (Optional) Anyscale Cloud ID.<br/><br/>This is used to lock down the cross account access role by Cloud ID. Because the Cloud ID is unique to each<br/>customer, this ensures that only the customer can access their own resources. The Cloud ID is not known until the<br/>Cloud is created, so this is an optional variable.<br/><br/>ex:<pre>anyscale_cloud_id = "cld_abcdefghijklmnop1234567890"</pre> | `string` | `null` | no |
| <a name="input_anyscale_cluster_node_byod_secret_arns"></a> [anyscale\_cluster\_node\_byod\_secret\_arns](#input\_anyscale\_cluster\_node\_byod\_secret\_arns) | (Optional) A list of Secrets Manager ARNs.<br/>The Secrets Manager secret ARNs that the cluster node role needs access to for BYOD clusters.<br/><br/>ex:<pre>anyscale_cluster_node_secret_arns = [<br/>  "arn:aws:secretsmanager:us-east-1:123456789012:secret:my-secret-1",<br/>  "arn:aws:secretsmanager:us-east-1:123456789012:secret:my-secret-2",<br/>]</pre> | `list(string)` | `[]` | no |
| <a name="input_anyscale_cluster_node_byod_secret_kms_arn"></a> [anyscale\_cluster\_node\_byod\_secret\_kms\_arn](#input\_anyscale\_cluster\_node\_byod\_secret\_kms\_arn) | (Optional) The KMS key ARN that the Secrets Manager secrets are encrypted with.<br/>This is only used if `anyscale_cluster_node_byod_secret_arns` is also provided.<br/><br/>ex:<pre>anyscale_cluster_node_secret_arns = [<br/>  "arn:aws:secretsmanager:us-east-1:123456789012:secret:my-secret-1",<br/>  "arn:aws:secretsmanager:us-east-1:123456789012:secret:my-secret-2",<br/>]<br/>anyscale_cluster_node_secret_kms_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"<br/># checkov:skip=CKV_SECRET_6</pre> | `string` | `null` | no |
| <a name="input_anyscale_org_id"></a> [anyscale\_org\_id](#input\_anyscale\_org\_id) | (Optional) Anyscale Organization ID.<br/><br/>This is used to lock down the cross account access role by Organization ID. Because the Organization ID is unique to each<br/>customer, this ensures that only the customer can access their own resources.<br/><br/>ex:<pre>anyscale_org_id = "org_abcdefghijklmn1234567890"</pre> | `string` | `null` | no |
| <a name="input_security_group_enable_ssh_access"></a> [security\_group\_enable\_ssh\_access](#input\_security\_group\_enable\_ssh\_access) | (Optional) Determines if SSH access (port 22) should be enabled in the security group.<br/><br/>When set to true, SSH access will be allowed from the CIDR ranges specified in<br/>`customer_ingress_cidr_ranges`. When false, only HTTPS access (port 443) will be allowed.<br/><br/>ex:<pre>security_group_enable_ssh_access = false</pre> | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags.<br/>These tags will be added to all cloud resources that accept tags.<br/>ex:<pre>tags = {<br/>  "environment" = "test",<br/>  "team" = "anyscale"<br/>}</pre> | `map(string)` | <pre>{<br/>  "environment": "test",<br/>  "test": true<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_anyscale_register_command"></a> [anyscale\_register\_command](#output\_anyscale\_register\_command) | Anyscale register command.<br/>This output can be used with the Anyscale CLI to register a new Anyscale Cloud.<br/>You will need to replace `<CUSTOMER_DEFINED_NAME>` with a name of your choosing before running the Anyscale CLI command. |
<!-- END_TF_DOCS -->
