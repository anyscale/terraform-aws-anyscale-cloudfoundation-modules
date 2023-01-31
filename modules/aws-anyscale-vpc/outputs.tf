output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = try(aws_vpc.anyscale_vpc[0].arn, "")
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = try(aws_vpc.anyscale_vpc[0].id, "")
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = try(aws_vpc.anyscale_vpc[0].cidr_block, "")
}

output "availability_zones" {
  description = "List of Availability Zones where subnets were created"
  value       = local.subnet_availability_zones
}

# Public Subnet and related resources
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = try(aws_subnet.public[*].id, [])
}

output "public_subnet_cidrs" {
  description = "IPv4 CIDR blocks for the public subnets"
  value       = try(aws_subnet.public[*].cidr_block, [])
}

output "public_route_table_ids" {
  description = "IDs of the public route tables"
  value       = try(aws_route_table.public[*].id, [])
}

# Private Subnets and related resources
output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = try(aws_subnet.private[*].id, [])
}
output "private_subnet_cidrs" {
  description = "IPv4 CIDR blocks for the private subnets"
  value       = try(aws_subnet.private[*].cidr_block, [])
}

output "private_route_table_ids" {
  description = "IDs of the private route tables"
  value       = try(aws_route_table.private[*].id, [])
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = try(aws_nat_gateway.nat_gateway[*].id, [])
}

output "nat_ips" {
  description = "Elastic IP Addresses created for NAT Gateway usage"
  value       = try(aws_eip.nat_gateway[*].public_ip, [])
}

# VPC Endpoints
#  After endpoints are created via Terraform, some additional resources are provisioned by AWS
#  that do not immediately appear in the resource, and therefore would not appear in the output
#  of the resources attributes. Examples include private DNS entries and Network Interface IDs.
#  We cannot refresh the resources and prevent Terraform from showing drift after creation,
#  but we can wait and populate the output from data sources to capture this additional information.

resource "time_sleep" "creation" {
  count = local.gateway_endpoints_enabled ? 1 : 0

  depends_on = [
    aws_vpc_endpoint.gateway_endpoint,
    aws_vpc_endpoint_route_table_association.gateway_endpoint
  ]

  create_duration = "30s"
}

data "aws_vpc_endpoint" "gateway_endpoint" {
  for_each = local.gateway_endpoints_enabled ? var.gateway_vpc_endpoints : {}

  id = aws_vpc_endpoint.gateway_endpoint[each.key].id

  depends_on = [time_sleep.creation]
}

output "gateway_vpc_endpoints_map" {
  value       = data.aws_vpc_endpoint.gateway_endpoint
  description = "Map of Gateway VPC Endpoints deployed to this VPC"
}
