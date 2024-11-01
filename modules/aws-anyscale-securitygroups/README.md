[![Build Status][badge-build]][build-status]
[![Terraform Version][badge-terraform]](https://github.com/hashicorp/terraform/releases)
[![AWS Provider Version][badge-tf-aws]](https://github.com/terraform-providers/terraform-provider-aws/releases)

# aws-anyscale-securitygroups
This sub-module creates the default Security Group resources needed for Anyscale to work in a customers environment.  It should be used from the [root module](../../README.md).

<!-- BEGIN_TF_DOCS -->
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

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_security_group.anyscale_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.anyscale_public_ingress_rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.egress_all_allowed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.egress_to_cidr_blocks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.egress_to_self](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_cidr_blocks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_with_existing_security_groups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_with_self](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | (Required) The ID of the VPC where the Security Group needs to be created. | `string` | n/a | yes |
| <a name="input_allow_all_egress"></a> [allow\_all\_egress](#input\_allow\_all\_egress) | (Optional) Determines of egress to all on cidr range 0.0.0.0/0 is allowed.<br/><br/>Changing this may have unintended consequences.<br/><br/>ex:<pre>allow_all_egress = true</pre> | `bool` | `true` | no |
| <a name="input_anyscale_cloud_id"></a> [anyscale\_cloud\_id](#input\_anyscale\_cloud\_id) | (Optional) Anyscale Cloud ID. Default is `null`. | `string` | `null` | no |
| <a name="input_anyscale_ingress_rules_v1"></a> [anyscale\_ingress\_rules\_v1](#input\_anyscale\_ingress\_rules\_v1) | (Deprecated) List of ingress rules to create. This is only used for Anyscale v1 stacks. | `list(string)` | <pre>[<br/>  "https-443-tcp",<br/>  "ssh-tcp"<br/>]</pre> | no |
| <a name="input_anyscale_public_ips_cidr"></a> [anyscale\_public\_ips\_cidr](#input\_anyscale\_public\_ips\_cidr) | (Deprecated) List of Anyscale Public IPs in CIDR format.<br/><br/>While optional, this is required for Anyscale v1 stack. | `list(string)` | <pre>[<br/>  "35.162.67.121/32",<br/>  "44.226.216.241/32",<br/>  "44.232.121.23/32",<br/>  "44.237.42.239/32",<br/>  "52.33.0.137/32"<br/>]</pre> | no |
| <a name="input_create_anyscale_public_ingress"></a> [create\_anyscale\_public\_ingress](#input\_create\_anyscale\_public\_ingress) | (Optional) Determines if public ingress rules should be created.<br/><br/>ex:<pre>create_anyscale_public_ingress = true</pre> | `bool` | `false` | no |
| <a name="input_create_security_group"></a> [create\_security\_group](#input\_create\_security\_group) | (Optional) Determines if a new security group should be created.<br/><br/>If not, an existing security group can be used as defined in `existing_security_group_id`.<br/><br/>ex:<pre>create_security_group = true</pre> | `bool` | `true` | no |
| <a name="input_default_egress_cidr_range"></a> [default\_egress\_cidr\_range](#input\_default\_egress\_cidr\_range) | (Optional) List of default IPv4 cidr ranges to use on egress rules.<br/><br/>ex:<pre>default_egress_cidr_range = ["0.0.0.0/0"]</pre> | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_default_ingress_cidr_range"></a> [default\_ingress\_cidr\_range](#input\_default\_ingress\_cidr\_range) | (Optional) List of IPv4 cidr ranges to default to if a specific mapping isn't provided.<br/><br/>ex:<pre>default_ingress_cidr_range = ["10.100.10.10/32"]</pre> | `list(string)` | `[]` | no |
| <a name="input_egress_to_cidr_map"></a> [egress\_to\_cidr\_map](#input\_egress\_to\_cidr\_map) | (Optional) List of egress rules to create with cidr ranges.<br/><br/>ex:<pre>egress_to_cidr_map = [<br/>  {<br/>    rule        = "https-443-tcp"<br/>    cidr_blocks = "0.0.0.0/0"<br/>  },<br/>  {<br/>    rule        = "http-80-tcp"<br/>    cidr_blocks = "0.0.0.0/0"<br/>  }<br/>]</pre> | `list(map(string))` | `[]` | no |
| <a name="input_egress_to_self"></a> [egress\_to\_self](#input\_egress\_to\_self) | (Optional) List of egress rules to create where 'self' is defined.<br/><br/>Changing this may have unintended consequences.<br/><br/>ex:<pre>egress_to_self = [<br/>  {<br/>    rule = "all-all"<br/>  }<br/>]</pre> | `list(map(string))` | <pre>[<br/>  {<br/>    "rule": "all-all"<br/>  }<br/>]</pre> | no |
| <a name="input_existing_security_group_id"></a> [existing\_security\_group\_id](#input\_existing\_security\_group\_id) | (Optional) An existing security group to update the rules on.<br/><br/>If `create_security_group` is set to false, this must be provided.<br/><br/>ex:<pre>existing_security_group_id = "sg-0123456789001ab8e"</pre> | `string` | `null` | no |
| <a name="input_ingress_from_cidr_map"></a> [ingress\_from\_cidr\_map](#input\_ingress\_from\_cidr\_map) | (Optional) List of ingress rules to create with cidr ranges.<br/><br/>ex:<pre>ingress_from_cidr_map = [<br/>  {<br/>    rule        = "https-443-tcp"<br/>    cidr_blocks = "10.100.10.10/32"<br/>  },<br/>  { rule = "nfs-tcp" },<br/>  {<br/>    rule        = "http-80-tcp"<br/>    cidr_blocks = "10.100.10.10/32"<br/>  },<br/>  {<br/>    from_port   = 10<br/>    to_port     = 20<br/>    protocol    = 6<br/>    description = "Service name is TEST"<br/>    cidr_blocks = "10.100.10.10/32"<br/>  }<br/>]</pre> | `list(map(string))` | `[]` | no |
| <a name="input_ingress_with_existing_security_groups_map"></a> [ingress\_with\_existing\_security\_groups\_map](#input\_ingress\_with\_existing\_security\_groups\_map) | (Optional) List of security groups and rules to allow ingress from.<br/><br/>ex:<pre>ingress_with_existing_security_groups_map = [<br/>  {<br/>    rule              = "https-443-tcp"<br/>    security_group_id = "sg-0123456789001ab8e"<br/>  },<br/>  {<br/>    rule              = "ssh-tcp"<br/>    security_group_id = "sg-0123456789001ab8e"<br/>  }<br/>]</pre> | `list(map(string))` | `[]` | no |
| <a name="input_ingress_with_self"></a> [ingress\_with\_self](#input\_ingress\_with\_self) | (Optional) List of ingress rules to create where 'self' is defined.<br/><br/>Default rule is `all-all` as this security group is used for all Anyscale resources.<br/><br/>ex:<pre>ingress_with_self = [<br/>  {<br/>    rule = "all-all"<br/>  }<br/>]</pre> | `list(map(string))` | <pre>[<br/>  {<br/>    "rule": "all-all"<br/>  }<br/>]</pre> | no |
| <a name="input_module_enabled"></a> [module\_enabled](#input\_module\_enabled) | (Optional) Whether to create the resources inside this module.<br/><br/>ex:<pre>module_enabled = true</pre> | `bool` | `true` | no |
| <a name="input_predefined_rules"></a> [predefined\_rules](#input\_predefined\_rules) | (Required) Map of predefined security group rules. | `map(list(any))` | <pre>{<br/>  "all-all": [<br/>    -1,<br/>    -1,<br/>    "-1",<br/>    "All protocols"<br/>  ],<br/>  "http-80-tcp": [<br/>    80,<br/>    80,<br/>    "tcp",<br/>    "HTTP"<br/>  ],<br/>  "https-443-tcp": [<br/>    443,<br/>    443,<br/>    "tcp",<br/>    "HTTPS"<br/>  ],<br/>  "nfs-tcp": [<br/>    2049,<br/>    2049,<br/>    "tcp",<br/>    "NFS/EFS"<br/>  ],<br/>  "ssh-tcp": [<br/>    22,<br/>    22,<br/>    "tcp",<br/>    "SSH"<br/>  ]<br/>}</pre> | no |
| <a name="input_revoke_rules_on_delete"></a> [revoke\_rules\_on\_delete](#input\_revoke\_rules\_on\_delete) | (Optional) Deterimines if Terraform needs to revoke all of the Security Group's attached ingress and egress rules before deleting the security group itself.<br/><br/>ex:<pre>revoke_rules_on_delete = true</pre> | `bool` | `false` | no |
| <a name="input_security_group_create_timeout"></a> [security\_group\_create\_timeout](#input\_security\_group\_create\_timeout) | (Optional) How long to wait for the security group to be created in minutes.<br/><br/>ex:<pre>security_group_create_timeout = "10m"</pre> | `string` | `"10m"` | no |
| <a name="input_security_group_delete_timeout"></a> [security\_group\_delete\_timeout](#input\_security\_group\_delete\_timeout) | (Optional) How long to wait for a deletion of a security group in minutes.<br/><br/>ex:<pre>security_group_delete_timeout = "15m"</pre> | `string` | `"15m"` | no |
| <a name="input_security_group_description"></a> [security\_group\_description](#input\_security\_group\_description) | (Optional) The security group description.<br/><br/>ex:<pre>security_group_description = "Anyscale Security Group"</pre> | `string` | `"Anyscale Security Group"` | no |
| <a name="input_security_group_name"></a> [security\_group\_name](#input\_security\_group\_name) | (Optional) The name for the security group.<br/><br/>If left `null`, will default to `security_group_name_prefix`.<br/>If provided, overrides the `security_group_name_prefix` variable.<br/><br/>ex:<pre>security_group_name = "anyscale-security-group"</pre> | `string` | `null` | no |
| <a name="input_security_group_name_prefix"></a> [security\_group\_name\_prefix](#input\_security\_group\_name\_prefix) | (Optional) The name prefix for the security group.<br/><br/>If `security_group_name` is provided, it will override this variable.<br/><br/>ex:<pre>security_group_name_prefix = "anyscale-security-group-"</pre> | `string` | `"anyscale-security-group-"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to all resources that accept tags.<br/><br/>ex:<pre>tags = {<br/>  test        = true<br/>  environment = "test"<br/>}</pre> | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | The ARN of the security group |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The ID of the security group |
| <a name="output_security_group_name"></a> [security\_group\_name](#output\_security\_group\_name) | The name of the security group |
<!-- END_TF_DOCS -->

<!-- References -->
[Terraform]: https://www.terraform.io
[Issues]: https://github.com/anyscale/sa-sandbox-terraform/issues
[badge-build]: https://github.com/anyscale/sa-sandbox-terraform/workflows/CI/CD%20Pipeline/badge.svg
[badge-terraform]: https://img.shields.io/badge/terraform-1.x%20-623CE4.svg?logo=terraform
[badge-tf-aws]: https://img.shields.io/badge/AWS-5.+-F8991D.svg?logo=terraform
[build-status]: https://github.com/anyscale/sa-sandbox-terraform/actions
