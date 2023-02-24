[![Build Status][badge-build]][build-status]
[![Terraform Version][badge-terraform]](https://github.com/hashicorp/terraform/releases)
[![AWS Provider Version][badge-tf-aws]](https://github.com/terraform-providers/terraform-provider-aws/releases)

# aws-anyscale-vpc
This module creates default VPC resources needed for Anyscale to work in a customers environment.
This builds a minimal VPC configuration. If you need more complex VPC configuration options...

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.55.0 |
| <a name="provider_time"></a> [time](#provider\_time) | 0.9.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.anyscale_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_eip.nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_flow_log.anyscale_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource |
| [aws_iam_policy.vpc_flow_log_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.anyscale_vpc_flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.vpc_flow_log_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_internet_gateway.anyscale_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route.private_route_ngw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public_route_igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.existing_one_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.anyscale_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_endpoint.gateway_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint_route_table_association.gateway_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_route_table_association) | resource |
| [aws_vpc_ipv4_cidr_block_association.anyscale_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_ipv4_cidr_block_association) | resource |
| [time_sleep.creation](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_availability_zones.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_iam_policy_document.flow_log_cloudwatch_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.vpc_flow_log_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_vpc_endpoint.gateway_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint) | data source |
| [aws_vpc_endpoint_service.gateway_endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_anyscale_cloud_id"></a> [anyscale\_cloud\_id](#input\_anyscale\_cloud\_id) | (Optional) Anyscale Cloud ID. Default is `null`. | `string` | `null` | no |
| <a name="input_anyscale_vpc_name"></a> [anyscale\_vpc\_name](#input\_anyscale\_vpc\_name) | (Optional) VPC name. Will default to `vpc_<anyscale_cloud_id>`. | `string` | `null` | no |
| <a name="input_availability_zone_ids"></a> [availability\_zone\_ids](#input\_availability\_zone\_ids) | (Optional) A list of availability zones ids in the region. Default is an empty list, and dynamically chosen. | `list(string)` | `[]` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | (Optional) A list of availability zones names in the region. Default is an empty list, and dynamically chosen. | `list(string)` | `[]` | no |
| <a name="input_cidr_block"></a> [cidr\_block](#input\_cidr\_block) | (Optional) The IPv4 CIDR block for the VPC. CIDR can be explicitly set or it can be derived from IPAM using `ipv4_netmask_length` & `ipv4_ipam_pool_id`. Default is `10.0.0.0/16` | `string` | `"10.0.0.0/16"` | no |
| <a name="input_create_flow_log_cloudwatch_iam_role"></a> [create\_flow\_log\_cloudwatch\_iam\_role](#input\_create\_flow\_log\_cloudwatch\_iam\_role) | (Optional) Determines whether to create IAM role for VPC Flow Logs. Default is `false`. | `bool` | `false` | no |
| <a name="input_create_flow_log_cloudwatch_log_group"></a> [create\_flow\_log\_cloudwatch\_log\_group](#input\_create\_flow\_log\_cloudwatch\_log\_group) | (Optional) Determines whether to create CloudWatch log group for VPC Flow Logs. Default is `false`. | `bool` | `false` | no |
| <a name="input_create_igw"></a> [create\_igw](#input\_create\_igw) | (Optional) Determines if an Internet Gateway is created for public subnets. Requires public\_subnets list to be provided. Default is `true`. | `bool` | `true` | no |
| <a name="input_create_ngw"></a> [create\_ngw](#input\_create\_ngw) | (Optional) Determines if a NAT Gateway should be created for private networks. Depends on Public/Private Subnets being created. Default is `true`. | `bool` | `true` | no |
| <a name="input_enable_vpc_dns_hostnames"></a> [enable\_vpc\_dns\_hostnames](#input\_enable\_vpc\_dns\_hostnames) | (Optional) Determines if DNS hostnames are enabled on the VPC. Default is `true` | `bool` | `true` | no |
| <a name="input_enable_vpc_dns_support"></a> [enable\_vpc\_dns\_support](#input\_enable\_vpc\_dns\_support) | (Optional) Determines if DNS support is enabled on the VPC. Default is `true`. | `bool` | `true` | no |
| <a name="input_enable_vpc_flow_logs"></a> [enable\_vpc\_flow\_logs](#input\_enable\_vpc\_flow\_logs) | (Optional) Determines if VPC Flow Logs should be enabled. Default is `false`. | `bool` | `false` | no |
| <a name="input_existing_private_subnet_ids"></a> [existing\_private\_subnet\_ids](#input\_existing\_private\_subnet\_ids) | (Optional)<br>A list of existing private subnets.<br>If this variable and var.existing\_vpc\_id are both provided, the aws-anyscale-vpc sub-module will not create a VPC or Subnets.<br>It will only create VPC Endpoints if the gateway\_vpc\_endpoints variable is defined.<br><br>Default is an empty list. | `list(string)` | `[]` | no |
| <a name="input_existing_route_table_ids"></a> [existing\_route\_table\_ids](#input\_existing\_route\_table\_ids) | (Optional)<br>A list of existing Route Tables.<br>If you are creating new private subnets in an existing VPC, this will provide the mapping from<br>subnet to route table. If only 1 is provided, all new subnets will be associated with that one.<br>If more than one, please make sure that you provide the same number of route tables as subnets.<br><br>Default is an empty list. | `list(string)` | `[]` | no |
| <a name="input_existing_vpc_id"></a> [existing\_vpc\_id](#input\_existing\_vpc\_id) | (Optional)<br>An existing VPC ID. If provided, this will skip creating an Anyscale VPC.<br>If no existing Subnet IDs are provided (`existing_subnet_ids`), but `existing_vpc_id` is provided, then new subnets will be created in this VPC.<br>Default is `null`. | `string` | `null` | no |
| <a name="input_flow_log_cloudwatch_log_group_kms_key_id"></a> [flow\_log\_cloudwatch\_log\_group\_kms\_key\_id](#input\_flow\_log\_cloudwatch\_log\_group\_kms\_key\_id) | (Optional) The ARN of the KMS Key to use when encrypting log data for VPC flow logs. Default is `null`. | `string` | `null` | no |
| <a name="input_flow_log_cloudwatch_log_group_name_prefix"></a> [flow\_log\_cloudwatch\_log\_group\_name\_prefix](#input\_flow\_log\_cloudwatch\_log\_group\_name\_prefix) | (Optional) Specifies the name prefix of CloudWatch Log Group for VPC flow logs. Default is `/aws/vpc-flow-log/` | `string` | `"/aws/vpc-flow-log/"` | no |
| <a name="input_flow_log_cloudwatch_log_group_name_suffix"></a> [flow\_log\_cloudwatch\_log\_group\_name\_suffix](#input\_flow\_log\_cloudwatch\_log\_group\_name\_suffix) | (Optional) Specifies the name suffix of CloudWatch Log Group for VPC flow logs. If none is provided, will append the VPC Name. Default is `null` | `string` | `null` | no |
| <a name="input_flow_log_cloudwatch_log_group_retention_in_days"></a> [flow\_log\_cloudwatch\_log\_group\_retention\_in\_days](#input\_flow\_log\_cloudwatch\_log\_group\_retention\_in\_days) | (Optional) Specifies the number of days you want to retain log events in the specified log group for VPC flow logs. Default is `null` which is unlimited. | `number` | `null` | no |
| <a name="input_gateway_vpc_endpoints"></a> [gateway\_vpc\_endpoints](#input\_gateway\_vpc\_endpoints) | A map of Gateway VPC Endpoints to provision into the VPC. This is a map of objects with the following attributes:<br>- `name`: Short service name (either "s3" or "dynamodb")<br>- `policy` = A policy (as JSON string) to attach to the endpoint that controls access to the service. May be `null` for full access.<br>Set to an empty map `{}` to skip creating VPC Endpoints.<br>Default is S3 with an empty (full access) policy. | <pre>map(object({<br>    name   = string<br>    policy = string<br>  }))</pre> | <pre>{<br>  "s3": {<br>    "name": "s3",<br>    "policy": null<br>  }<br>}</pre> | no |
| <a name="input_ipv4_ipam_pool_id"></a> [ipv4\_ipam\_pool\_id](#input\_ipv4\_ipam\_pool\_id) | (Optional) The ID of an IPv4 IPAM pool you want to use for allocating this VPC's CIDR. Default is `null`. | `string` | `null` | no |
| <a name="input_ipv4_netmask_length"></a> [ipv4\_netmask\_length](#input\_ipv4\_netmask\_length) | (Optional) The netmask length of the IPv4 CIDR you want to allocate to this VPC. Requires specifying a ipv4\_ipam\_pool\_id. Default is `null`. | `number` | `null` | no |
| <a name="input_map_public_ip_on_launch"></a> [map\_public\_ip\_on\_launch](#input\_map\_public\_ip\_on\_launch) | (Optional) Determines if public subnets should auto-assign public IPs on launch. Defualt is `true`. | `bool` | `true` | no |
| <a name="input_max_az_count"></a> [max\_az\_count](#input\_max\_az\_count) | (Optional) The max count of availability zones to use/identify. Default is `0`. | `number` | `0` | no |
| <a name="input_max_nat_gateway_count"></a> [max\_nat\_gateway\_count](#input\_max\_nat\_gateway\_count) | Upper limit on number of NAT Gateways to create. Set to `1` to only create one NAT Gateway. Default is `999` but will default to number of availability zones as the max. | `number` | `999` | no |
| <a name="input_module_enabled"></a> [module\_enabled](#input\_module\_enabled) | (Optional) Whether to create the resources inside this module. Default is `true`. | `bool` | `true` | no |
| <a name="input_nat_gateway_destination_cidr_block"></a> [nat\_gateway\_destination\_cidr\_block](#input\_nat\_gateway\_destination\_cidr\_block) | (Optional) Defines a custom destination route for NAT Gateway(s). Default is `0.0.0.0/0`. | `string` | `"0.0.0.0/0"` | no |
| <a name="input_private_subnet_names"></a> [private\_subnet\_names](#input\_private\_subnet\_names) | (Optional) Explicit values to use in the Name tag on private subnets. If empty, Name tags are generated. Default is an empty list. | `list(string)` | `[]` | no |
| <a name="input_private_subnet_suffix"></a> [private\_subnet\_suffix](#input\_private\_subnet\_suffix) | (Optional) Suffix to append to private subnets name. Default is `private`. | `string` | `"private"` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | (Optional)<br>A list of private subnets inside a VPC.<br>If you are creating subnets in an existing VPC (using existing\_vpc\_id),<br>please make sure that the number of subnets in the list is less than or<br>equal to the number of AZ's in the region.<br><br>Default is an empty list. | `list(string)` | `[]` | no |
| <a name="input_public_subnet_names"></a> [public\_subnet\_names](#input\_public\_subnet\_names) | (Optional) Explicit values to use in the Name tag on public subnets. If empty, Name tags are generated. Default is an empty list. | `list(string)` | `[]` | no |
| <a name="input_public_subnet_suffix"></a> [public\_subnet\_suffix](#input\_public\_subnet\_suffix) | (Optional) Suffix to append to public subnets name. Default is `public` | `string` | `"public"` | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | (Optional)<br>A list of public subnets inside the VPC.<br>If you are creating subnets in an existing VPC (using existing\_vpc\_id),<br>please make sure that the number of subnets in the list is less than or<br>equal to the number of AZ's in the region.<br><br>Default is an empty list. | `list(string)` | `[]` | no |
| <a name="input_secondary_cidr_blocks"></a> [secondary\_cidr\_blocks](#input\_secondary\_cidr\_blocks) | (Optional) List of secondary CIDR blocks to associate with the VPC to extend the IP Address pool. Default is an empty list. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. Default is none. | `map(string)` | `{}` | no |
| <a name="input_use_ipam_pool"></a> [use\_ipam\_pool](#input\_use\_ipam\_pool) | (Optional) Determines whether IPAM pool is used for CIDR allocation. Default is `false` | `bool` | `false` | no |
| <a name="input_vpc_flow_log_permissions_boundary"></a> [vpc\_flow\_log\_permissions\_boundary](#input\_vpc\_flow\_log\_permissions\_boundary) | (Optional) ARN of a Permissions Boundary for the VPC Flow Log IAM Role. Default is `null` | `string` | `null` | no |
| <a name="input_vpc_instance_tenancy"></a> [vpc\_instance\_tenancy](#input\_vpc\_instance\_tenancy) | (Optional) A tenancy option for instances launched into the VPC. Default is `default` | `string` | `"default"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_availability_zones"></a> [availability\_zones](#output\_availability\_zones) | List of Availability Zones where subnets were created |
| <a name="output_gateway_vpc_endpoints_map"></a> [gateway\_vpc\_endpoints\_map](#output\_gateway\_vpc\_endpoints\_map) | Map of Gateway VPC Endpoints deployed to this VPC |
| <a name="output_nat_gateway_ids"></a> [nat\_gateway\_ids](#output\_nat\_gateway\_ids) | IDs of the NAT Gateways |
| <a name="output_nat_ips"></a> [nat\_ips](#output\_nat\_ips) | Elastic IP Addresses created for NAT Gateway usage |
| <a name="output_private_route_table_ids"></a> [private\_route\_table\_ids](#output\_private\_route\_table\_ids) | IDs of the private route tables |
| <a name="output_private_subnet_cidrs"></a> [private\_subnet\_cidrs](#output\_private\_subnet\_cidrs) | IPv4 CIDR blocks for the private subnets |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | IDs of the private subnets |
| <a name="output_public_route_table_ids"></a> [public\_route\_table\_ids](#output\_public\_route\_table\_ids) | IDs of the public route tables |
| <a name="output_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#output\_public\_subnet\_cidrs) | IPv4 CIDR blocks for the public subnets |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | IDs of the public subnets |
| <a name="output_vpc_arn"></a> [vpc\_arn](#output\_vpc\_arn) | The ARN of the VPC |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | The CIDR block of the VPC |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- References -->
[Terraform]: https://www.terraform.io
[Issues]: https://github.com/anyscale/sa-sandbox-terraform/issues
[badge-build]: https://github.com/anyscale/sa-sandbox-terraform/workflows/CI/CD%20Pipeline/badge.svg
[badge-terraform]: https://img.shields.io/badge/terraform-1.x%20-623CE4.svg?logo=terraform
[badge-tf-aws]: https://img.shields.io/badge/AWS-4.+-F8991D.svg?logo=terraform
[build-status]: https://github.com/anyscale/sa-sandbox-terraform/actions
