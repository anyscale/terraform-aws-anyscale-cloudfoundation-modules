[![Build Status][badge-build]][build-status]
[![Terraform Version][badge-terraform]](https://github.com/hashicorp/terraform/releases)
[![AWS Provider Version][badge-tf-aws]](https://github.com/terraform-providers/terraform-provider-aws/releases)

# aws-anyscale-securitygroups
This sub-module creates the default Security Group resources needed for Anyscale to work in a customers environment.  It should be used from the [root module](../../README.md).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0, < 7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_security_group.anyscale_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.machine_pool](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.egress_all_allowed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.egress_to_cidr_blocks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.egress_to_self](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_from_cidr_blocks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_with_existing_security_groups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_with_self](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.machine_pool_egress_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.machine_pool_ports_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.main_from_machine_pool](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | (Required) The ID of the VPC where the Security Group needs to be created. | `string` | n/a | yes |
| <a name="input_allow_all_egress"></a> [allow\_all\_egress](#input\_allow\_all\_egress) | (Optional) Determines of egress to all on cidr range 0.0.0.0/0 is allowed.<br/><br/>Changing this may have unintended consequences.<br/><br/>ex:<pre>allow_all_egress = true</pre> | `bool` | `true` | no |
| <a name="input_anyscale_cloud_id"></a> [anyscale\_cloud\_id](#input\_anyscale\_cloud\_id) | (Optional) Anyscale Cloud ID. Default is `null`. | `string` | `null` | no |
| <a name="input_create_security_group"></a> [create\_security\_group](#input\_create\_security\_group) | (Optional) Determines if a new security group should be created.<br/><br/>If not, an existing security group can be used as defined in `existing_security_group_id`.<br/><br/>ex:<pre>create_security_group = true</pre> | `bool` | `true` | no |
| <a name="input_default_egress_cidr_range"></a> [default\_egress\_cidr\_range](#input\_default\_egress\_cidr\_range) | (Optional) List of default IPv4 cidr ranges to use on egress rules.<br/><br/>ex:<pre>default_egress_cidr_range = ["0.0.0.0/0"]</pre> | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_default_ingress_cidr_range"></a> [default\_ingress\_cidr\_range](#input\_default\_ingress\_cidr\_range) | (Optional) List of IPv4 cidr ranges to default to if a specific mapping isn't provided.<br/><br/>ex:<pre>default_ingress_cidr_range = ["10.100.10.10/32"]</pre> | `list(string)` | `[]` | no |
| <a name="input_egress_to_cidr_map"></a> [egress\_to\_cidr\_map](#input\_egress\_to\_cidr\_map) | (Optional) List of egress rules to create with cidr ranges.<br/><br/>ex:<pre>egress_to_cidr_map = [<br/>  {<br/>    rule        = "https-443-tcp"<br/>    cidr_blocks = "0.0.0.0/0"<br/>  },<br/>  {<br/>    rule        = "http-80-tcp"<br/>    cidr_blocks = "0.0.0.0/0"<br/>  }<br/>]</pre> | `list(map(string))` | `[]` | no |
| <a name="input_egress_to_self"></a> [egress\_to\_self](#input\_egress\_to\_self) | (Optional) List of egress rules to create where 'self' is defined.<br/><br/>Changing this may have unintended consequences.<br/><br/>ex:<pre>egress_to_self = [<br/>  {<br/>    rule = "all-all"<br/>  }<br/>]</pre> | `list(map(string))` | <pre>[<br/>  {<br/>    "rule": "all-all"<br/>  }<br/>]</pre> | no |
| <a name="input_existing_security_group_id"></a> [existing\_security\_group\_id](#input\_existing\_security\_group\_id) | (Optional) An existing security group to update the rules on.<br/><br/>If `create_security_group` is set to false, this must be provided.<br/><br/>ex:<pre>existing_security_group_id = "sg-0123456789001ab8e"</pre> | `string` | `null` | no |
| <a name="input_ingress_from_cidr_map"></a> [ingress\_from\_cidr\_map](#input\_ingress\_from\_cidr\_map) | (Optional) List of ingress rules to create with cidr ranges.<br/><br/>ex:<pre>ingress_from_cidr_map = [<br/>  {<br/>    rule        = "https-443-tcp"<br/>    cidr_blocks = "10.100.10.10/32"<br/>  },<br/>  { rule = "nfs-tcp" },<br/>  {<br/>    rule        = "http-80-tcp"<br/>    cidr_blocks = "10.100.10.10/32"<br/>  },<br/>  {<br/>    from_port   = 10<br/>    to_port     = 20<br/>    protocol    = 6<br/>    description = "Service name is TEST"<br/>    cidr_blocks = "10.100.10.10/32"<br/>  }<br/>]</pre> | `list(map(string))` | `[]` | no |
| <a name="input_ingress_with_existing_security_groups_map"></a> [ingress\_with\_existing\_security\_groups\_map](#input\_ingress\_with\_existing\_security\_groups\_map) | (Optional) List of security groups and rules to allow ingress from.<br/><br/>ex:<pre>ingress_with_existing_security_groups_map = [<br/>  {<br/>    rule              = "https-443-tcp"<br/>    security_group_id = "sg-0123456789001ab8e"<br/>  },<br/>  {<br/>    rule              = "ssh-tcp"<br/>    security_group_id = "sg-0123456789001ab8e"<br/>  }<br/>]</pre> | `list(map(string))` | `[]` | no |
| <a name="input_ingress_with_self"></a> [ingress\_with\_self](#input\_ingress\_with\_self) | (Optional) List of ingress rules to create where 'self' is defined.<br/><br/>Default rule is `all-all` as this security group is used for all Anyscale resources.<br/><br/>ex:<pre>ingress_with_self = [<br/>  {<br/>    rule = "all-all"<br/>  }<br/>]</pre> | `list(map(string))` | <pre>[<br/>  {<br/>    "rule": "all-all"<br/>  }<br/>]</pre> | no |
| <a name="input_machine_pool_cidr_ranges"></a> [machine\_pool\_cidr\_ranges](#input\_machine\_pool\_cidr\_ranges) | (Optional) List of CIDR ranges to allow ingress from machine pools.<br/><br/>**IMPORTANT**: Due to AWS security group limits (60 rules max) and the number of port ranges (22),<br/>this variable is limited to a maximum of 2 CIDR ranges. With 3 or more CIDR ranges, you would exceed<br/>the AWS security group rule limit (22 port ranges × 3 CIDR ranges = 66 rules > 60 limit).<br/><br/>ex:<pre>machine_pool_cidr_ranges = ["10.100.10.0/24", "10.100.11.0/24"]</pre> | `list(string)` | `[]` | no |
| <a name="input_machine_pool_port_ranges"></a> [machine\_pool\_port\_ranges](#input\_machine\_pool\_port\_ranges) | (Optional) List of port ranges for machine pools. Each range will create a separate security group rule. | <pre>list(object({<br/>    from_port   = number<br/>    to_port     = number<br/>    description = string<br/>  }))</pre> | <pre>[<br/>  {<br/>    "description": "HTTP",<br/>    "from_port": 80,<br/>    "to_port": 80<br/>  },<br/>  {<br/>    "description": "HTTPS",<br/>    "from_port": 443,<br/>    "to_port": 443<br/>  },<br/>  {<br/>    "description": "Anyscale Services (1010-1012)",<br/>    "from_port": 1010,<br/>    "to_port": 1012<br/>  },<br/>  {<br/>    "description": "SSH Alternative",<br/>    "from_port": 2222,<br/>    "to_port": 2222<br/>  },<br/>  {<br/>    "description": "Anyscale Service",<br/>    "from_port": 5555,<br/>    "to_port": 5555<br/>  },<br/>  {<br/>    "description": "VNC",<br/>    "from_port": 5903,<br/>    "to_port": 5903<br/>  },<br/>  {<br/>    "description": "Redis",<br/>    "from_port": 6379,<br/>    "to_port": 6379<br/>  },<br/>  {<br/>    "description": "Anyscale Services (6822-6824)",<br/>    "from_port": 6822,<br/>    "to_port": 6824<br/>  },<br/>  {<br/>    "description": "Anyscale Service",<br/>    "from_port": 6826,<br/>    "to_port": 6826<br/>  },<br/>  {<br/>    "description": "Anyscale Service",<br/>    "from_port": 7878,<br/>    "to_port": 7878<br/>  },<br/>  {<br/>    "description": "Health Checks",<br/>    "from_port": 8000,<br/>    "to_port": 8000<br/>  },<br/>  {<br/>    "description": "Anyscale Service",<br/>    "from_port": 8076,<br/>    "to_port": 8076<br/>  },<br/>  {<br/>    "description": "Anyscale Service",<br/>    "from_port": 8085,<br/>    "to_port": 8085<br/>  },<br/>  {<br/>    "description": "Anyscale Service",<br/>    "from_port": 8201,<br/>    "to_port": 8201<br/>  },<br/>  {<br/>    "description": "Anyscale Services (8265-8266)",<br/>    "from_port": 8265,<br/>    "to_port": 8266<br/>  },<br/>  {<br/>    "description": "Anyscale Services (8686-8687)",<br/>    "from_port": 8686,<br/>    "to_port": 8687<br/>  },<br/>  {<br/>    "description": "Anyscale Service",<br/>    "from_port": 8912,<br/>    "to_port": 8912<br/>  },<br/>  {<br/>    "description": "Anyscale Service",<br/>    "from_port": 8999,<br/>    "to_port": 8999<br/>  },<br/>  {<br/>    "description": "Prometheus",<br/>    "from_port": 9090,<br/>    "to_port": 9090<br/>  },<br/>  {<br/>    "description": "Kafka",<br/>    "from_port": 9092,<br/>    "to_port": 9092<br/>  },<br/>  {<br/>    "description": "Node Exporter",<br/>    "from_port": 9100,<br/>    "to_port": 9100<br/>  },<br/>  {<br/>    "description": "Anyscale Services (9478-9482)",<br/>    "from_port": 9478,<br/>    "to_port": 9482<br/>  }<br/>]</pre> | no |
| <a name="input_machine_pool_security_group_description"></a> [machine\_pool\_security\_group\_description](#input\_machine\_pool\_security\_group\_description) | (Optional) Description for the machine pool security group.<br/><br/>ex:<pre>machine_pool_security_group_description = "Anyscale Machine Pool Security Group"</pre> | `string` | `"Anyscale Machine Pool Security Group"` | no |
| <a name="input_machine_pool_security_group_name"></a> [machine\_pool\_security\_group\_name](#input\_machine\_pool\_security\_group\_name) | (Optional) Name for the machine pool security group.<br/><br/>ex:<pre>machine_pool_security_group_name = "anyscale-machine-pool-sg"</pre> | `string` | `null` | no |
| <a name="input_machine_pool_security_group_name_prefix"></a> [machine\_pool\_security\_group\_name\_prefix](#input\_machine\_pool\_security\_group\_name\_prefix) | (Optional) Name prefix for the machine pool security group.<br/><br/>ex:<pre>machine_pool_security_group_name_prefix = "anyscale-machine-pool-sg-"</pre> | `string` | `"anyscale-machine-pool-sg-"` | no |
| <a name="input_module_enabled"></a> [module\_enabled](#input\_module\_enabled) | (Optional) Whether to create the resources inside this module.<br/><br/>ex:<pre>module_enabled = true</pre> | `bool` | `true` | no |
| <a name="input_predefined_rules"></a> [predefined\_rules](#input\_predefined\_rules) | (Required) Map of predefined security group rules. | <pre>map(object({<br/>    from_port   = number<br/>    to_port     = number<br/>    protocol    = string<br/>    description = string<br/>  }))</pre> | <pre>{<br/>  "all-all": {<br/>    "description": "All protocols",<br/>    "from_port": -1,<br/>    "protocol": "-1",<br/>    "to_port": -1<br/>  },<br/>  "health-checks": {<br/>    "description": "Health Checks",<br/>    "from_port": 8000,<br/>    "protocol": "tcp",<br/>    "to_port": 8000<br/>  },<br/>  "http-80-tcp": {<br/>    "description": "HTTP",<br/>    "from_port": 80,<br/>    "protocol": "tcp",<br/>    "to_port": 80<br/>  },<br/>  "https-443-tcp": {<br/>    "description": "HTTPS",<br/>    "from_port": 443,<br/>    "protocol": "tcp",<br/>    "to_port": 443<br/>  },<br/>  "nfs-tcp": {<br/>    "description": "NFS/EFS",<br/>    "from_port": 2049,<br/>    "protocol": "tcp",<br/>    "to_port": 2049<br/>  },<br/>  "ssh-tcp": {<br/>    "description": "SSH",<br/>    "from_port": 22,<br/>    "protocol": "tcp",<br/>    "to_port": 22<br/>  }<br/>}</pre> | no |
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
| <a name="output_machine_pool_security_group_arn"></a> [machine\_pool\_security\_group\_arn](#output\_machine\_pool\_security\_group\_arn) | The ARN of the machine pool security group |
| <a name="output_machine_pool_security_group_id"></a> [machine\_pool\_security\_group\_id](#output\_machine\_pool\_security\_group\_id) | The ID of the machine pool security group |
| <a name="output_machine_pool_security_group_name"></a> [machine\_pool\_security\_group\_name](#output\_machine\_pool\_security\_group\_name) | The name of the machine pool security group |
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | The ARN of the security group |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The ID of the security group |
| <a name="output_security_group_name"></a> [security\_group\_name](#output\_security\_group\_name) | The name of the security group |
<!-- END_TF_DOCS -->

<!-- References -->
[Terraform]: https://www.terraform.io
[Anyscale]: https://www.anyscale.com
[Issues]: https://github.com/anyscale/terraform-aws-anyscale-cloudfoundation-modules/issues
[badge-release]: https://img.shields.io/github/v/release/anyscale/terraform-aws-anyscale-cloudfoundation-modules.svg?style=for-the-badge&labelColor=0066FF&color=CCE0FF
[badge-build]: https://img.shields.io/github/actions/workflow/status/anyscale/terraform-aws-anyscale-cloudfoundation-modules/main.yml?style=for-the-badge
[badge-terraform]: https://img.shields.io/badge/terraform-1.9.x+%20-623CE4.svg?logo=terraform&style=for-the-badge&labelColor=DDDDDD
[badge-tf-aws]: https://img.shields.io/badge/AWS-5.+_or_6.+-F8991D.svg?logo=terraform&style=for-the-badge&labelColor=DDDDDD
[badge-anyscale-cli]: https://img.shields.io/badge/anyscale%20cli-0.26.40+-0066FF.svg?style=for-the-badge&labelColor=CCE0FF&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAzIiBoZWlnaHQ9IjIwMyIgdmlld0JveD0iMCAwIDIwMyAyMDMiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxwYXRoIGQ9Ik0xNDMuNzg5IDEwNC42NzVMMTE2LjMyMyAxNTIuMjUySDE3MS42MzVDMTczLjY2NiAxNTIuMjUyIDE3NS41NDUgMTUxLjE3IDE3Ni41NyAxNDkuNDA1TDIwMi4zOTUgMTA0LjY3NUgxNDMuNzg5WiIgZmlsbD0iIzAwNjZGRiIvPgo8cGF0aCBkPSJNMjAyLjM5NSA5OC4zMjUzTDE3Ni41NyA1My41OTQ5QzE3NS41NTUgNTEuODI5NiAxNzMuNjc2IDUwLjc0NzYgMTcxLjYzNSA1MC43NDc2SDExNi4zMjNMMTQzLjc4OSA5OC4zMjUzSDIwMi4zOTVaIiBmaWxsPSIjMDA2NkZGIi8+CjxwYXRoIGQ9Ik02MS4zODk0IDUwLjc0NzZIMTE2LjMyMkw4OC42NjYxIDIuODQ3MjZDODcuNjUwNiAxLjA4MTk2IDg1Ljc3MTQgMCA4My43MzA5IDBIMzIuMDgxNkw2MS4zNzk5IDUwLjc0NzZINjEuMzg5NFoiIGZpbGw9IiMwMDY2RkYiLz4KPHBhdGggZD0iTTI2LjU4NjQgMy4xNjk5NUwwLjc2MTc2NCA0Ny45MDA0Qy0wLjI1Mzc1OCA0OS42NjU3IC0wLjI1Mzc1OCA1MS44Mjk2IDAuNzYxNzY0IDUzLjU5NDlMMjguNDE4MSAxMDEuNDk1TDU1Ljg4NDcgNTMuOTE3NkwyNi41ODY0IDMuMTY5OTVaIiBmaWxsPSIjMDA2NkZGIi8+CjxwYXRoIGQ9Ik01NS44OTQyIDE0OS4wNzNMMjguNDI3NiAxMDEuNDk1TDAuNzYxNzY0IDE0OS40MDVDLTAuMjUzNzU4IDE1MS4xNyAtMC4yNTM3NTggMTUzLjMzNCAwLjc2MTc2NCAxNTUuMUwyNi41ODY0IDE5OS44M0w1NS44ODQ3IDE0OS4wODJMNTUuODk0MiAxNDkuMDczWiIgZmlsbD0iIzAwNjZGRiIvPgo8cGF0aCBkPSJNMzIuMDgxNiAyMDNIODMuNzMwOUM4NS43NjE5IDIwMyA4Ny42NDExIDIwMS45MTggODguNjY2MSAyMDAuMTUzTDExNi4zMjIgMTUyLjI1Mkg2MS4zODk0TDMyLjA5MTEgMjAzSDMyLjA4MTZaIiBmaWxsPSIjMDA2NkZGIi8+Cjwvc3ZnPg==
[build-status]: https://github.com/anyscale/terraform-aws-anyscale-cloudfoundation-modules/actions
