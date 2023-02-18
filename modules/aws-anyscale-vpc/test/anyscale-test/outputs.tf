# --------------
# Defaults Test
# --------------
output "all_defaults_arn" {
  description = "The arn of the anyscale resource."
  value       = module.all_defaults.vpc_arn
}

output "all_defaults_id" {
  description = "The ID of the anyscale resource."
  value       = module.all_defaults.vpc_id
}

output "all_defaults_cidr_range" {
  description = "The CIDR Range of the anyscale resource."
  value       = module.all_defaults.vpc_cidr_block
}

# ------------------------
# Minimum VPC needed Test
# ------------------------
output "minimum_anyscale_vpc_requirements_arn" {
  description = "The arn of the anyscale resource."
  value       = module.minimum_anyscale_vpc_requirements.vpc_arn
}

output "minimum_anyscale_vpc_requirements_id" {
  description = "The ID of the anyscale resource."
  value       = module.minimum_anyscale_vpc_requirements.vpc_id
}

output "minimum_anyscale_vpc_requirements_cidr_range" {
  description = "The CIDR Range of the anyscale resource."
  value       = module.minimum_anyscale_vpc_requirements.vpc_cidr_block
}

# --------------------------------
# Public/Private Subnets VPC Test
# --------------------------------
output "public_private_vpc_arn" {
  description = "The arn of the anyscale resource."
  value       = module.public_private_vpc.vpc_arn
}

output "public_private_vpc_id" {
  description = "The ID of the anyscale resource."
  value       = module.public_private_vpc.vpc_id
}

output "public_private_vpc_cidr_range" {
  description = "The CIDR Range of the anyscale resource."
  value       = module.public_private_vpc.vpc_cidr_block
}

output "public_private_availability_zones" {
  description = "The Availability Zones of the anyscale public/private test vpc"
  value       = module.public_private_vpc.availability_zones
}

output "public_private_public_subnet_cidrs" {
  description = "The public subnet cidrs of the anyscale public/private test vpc"
  value       = module.public_private_vpc.public_subnet_cidrs
}

output "public_private_private_subnet_cidrs" {
  description = "The private subnet cidrs of the anyscale public/private test vpc"
  value       = module.public_private_vpc.private_subnet_cidrs
}

output "public_private_nat_gateway_ids" {
  description = "The nat gateway ids of the anyscale public/private test vpc"
  value       = module.public_private_vpc.nat_gateway_ids
}

# --------------------------------
# New Subnets - Existing VPC Test
# --------------------------------
output "new_subnets_existing_vpc_vpc_id" {
  description = "The ID of the anyscale resource."
  value       = module.existing_vpc_new_subnets.vpc_id
}
output "new_subnets_existing_vpc_subnet_cidrs" {
  description = "The private subnet cidrs of the anyscale new subnets existing vpc test"
  value       = module.kitchen_sink.private_subnet_cidrs
}

# ------------------
# Kitchen Sink Test
# ------------------
output "kitchen_sink_vpc_arn" {
  description = "The arn of the anyscale resource."
  value       = module.kitchen_sink.vpc_arn
}

output "kitchen_sink_vpc_id" {
  description = "The ID of the anyscale resource."
  value       = module.kitchen_sink.vpc_id
}

output "kitchen_sink_vpc_cidr_range" {
  description = "The CIDR Range of the anyscale resource."
  value       = module.kitchen_sink.vpc_cidr_block
}

output "kitchen_sink_availability_zones" {
  description = "The Availability Zones of the anyscale kitchen sink test vpc"
  value       = module.kitchen_sink.availability_zones
}

output "kitchen_sink_public_subnet_cidrs" {
  description = "The public subnet cidrs of the anyscale kitchen sink test vpc"
  value       = module.kitchen_sink.public_subnet_cidrs
}

output "kitchen_sink_private_subnet_cidrs" {
  description = "The private subnet cidrs of the anyscale kitchen sink test vpc"
  value       = module.kitchen_sink.private_subnet_cidrs
}

output "kitchen_sink_nat_gateway_ids" {
  description = "The nat gateway ids of the anyscale kitchen sink test vpc"
  value       = module.kitchen_sink.nat_gateway_ids
}


# -----------------
# No resource test
# -----------------
output "test_no_resources" {
  description = "The outputs of the no_resource resource - should all be empty"
  value       = module.test_no_resources
}
