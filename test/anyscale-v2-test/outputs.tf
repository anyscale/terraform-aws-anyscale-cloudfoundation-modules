# ---------------------------------------------------------------------------------------------------------------------
# Anyscale v2 Stack resources with minimal parameters
# ---------------------------------------------------------------------------------------------------------------------
output "anyscale_v2_vpc_id" {
  description = "Anyscale VPC ID. If there was not one created, return the one that was used during other resource creation."
  value       = try(module.aws_anyscale_v2.anyscale_vpc_id, "")
}

output "anyscale_v2_vpc_public_subnet_ids" {
  description = "Anyscale VPC Public Subnet IDs. If there were none created, return an empty string."
  value       = try(module.aws_anyscale_v2.anyscale_vpc_public_subnet_ids, [])
}
output "anyscale_v2_vpc_private_subnet_ids" {
  description = "Anyscale VPC Private Subnet IDs. If there were none created, return an empty string."
  value       = try(module.aws_anyscale_v2.anyscale_vpc_private_subnet_ids, [])
}

output "anyscale_v2_s3_bucket_id" {
  description = "Anyscale S3 Bucket ID. If a bucket was not created, return an empty string."
  value       = try(module.aws_anyscale_v2.anyscale_s3_bucket_id, "")
}

output "anyscale_v2_security_group_id" {
  description = "Anyscale Security Group ID. If a security group was not created, return an empty string."
  value       = try(module.aws_anyscale_v2.anyscale_security_group_id, "")
}

output "anyscale_v2_iam_role_arn" {
  description = "Anyscale IAM access role arn."
  value       = try(module.aws_anyscale_v2.anyscale_iam_role_arn, "")
}

output "anyscale_v2_iam_instance_role_arn" {
  description = "Anyscale IAM instance role arn."
  value       = try(module.aws_anyscale_v2.anyscale_iam_role_cluster_node_arn, "")
}

output "anyscale_v2_efs_id" {
  description = "Anyscale Elastic File System ID."
  value       = try(module.aws_anyscale_v2.anyscale_efs_id, "")
}

# ---------------------------------------------------------------------------------------------------------------------
# Anyscale v2 Stack with existing VPC
# ---------------------------------------------------------------------------------------------------------------------
output "anyscale_v2_existing_vpc_s3_bucket_id" {
  description = "Anyscale S3 Bucket ID. If a bucket was not created, return an empty string."
  value       = try(module.aws_anyscale_v2_existing_vpc.anyscale_s3_bucket_id, "")
}

output "anyscale_v2_existing_vpc_security_group_id" {
  description = "Anyscale Security Group ID. If a security group was not created, return an empty string."
  value       = try(module.aws_anyscale_v2_existing_vpc.anyscale_security_group_id, "")
}

output "anyscale_v2_existing_vpc_iam_role_arn" {
  description = "Anyscale IAM access role arn."
  value       = try(module.aws_anyscale_v2_existing_vpc.anyscale_iam_role_arn, "")
}

output "anyscale_v2_existing_vpc_iam_instance_role_arn" {
  description = "Anyscale IAM instance role arn."
  value       = try(module.aws_anyscale_v2_existing_vpc.anyscale_iam_role_cluster_node_arn, "")
}

output "anyscale_v2_existing_vpc_efs_id" {
  description = "Anyscale Elastic File System ID."
  value       = try(module.aws_anyscale_v2_existing_vpc.anyscale_efs_id, "")
}


# ---------------------------------------------------------------------------------------------------------------------
# Anyscale v2 Stack with existing VPC and existing S3 Bucket
# ---------------------------------------------------------------------------------------------------------------------
# output "anyscale_v2_existing_vpc_existing_s3_security_group_id" {
#   description = "Anyscale Security Group ID. If a security group was not created, return an empty string."
#   value       = try(module.aws_anyscale_v2_existing_vpc_existing_s3.anyscale_security_group_id, "")
# }

# output "anyscale_v2_existing_existing_s3_vpc_iam_role_arn" {
#   description = "Anyscale IAM access role arn."
#   value       = try(module.aws_anyscale_v2_existing_vpc_existing_s3.anyscale_iam_role_arn, "")
# }

# output "anyscale_v2_existing_vpc_existing_s3_iam_instance_role_arn" {
#   description = "Anyscale IAM instance role arn."
#   value       = try(module.aws_anyscale_v2_existing_vpc_existing_s3.anyscale_iam_role_cluster_node_arn, "")
# }

# output "anyscale_v2_existing_vpc_existing_s3_efs_id" {
#   description = "Anyscale Elastic File System ID."
#   value       = try(module.aws_anyscale_v2_existing_vpc_existing_s3.anyscale_efs_id, "")
# }

# ---------------------------------------------------------------------------------------------------------------------
# Anyscale v2 Stack with private VPC
# ---------------------------------------------------------------------------------------------------------------------
output "anyscale_v2_private_vpc_id" {
  description = "Anyscale VPC ID. If there was not one created, return the one that was used during other resource creation."
  value       = try(module.aws_anyscale_v2_private_vpc.anyscale_vpc_id, "")
}

output "anyscale_v2_private_vpc_public_subnet_ids" {
  description = "Anyscale VPC Public Subnet IDs. If there were none created, return an empty string."
  value       = try(module.aws_anyscale_v2_private_vpc.anyscale_vpc_public_subnet_ids, [])
}
output "anyscale_v2_private_vpc_private_subnet_ids" {
  description = "Anyscale VPC Private Subnet IDs. If there were none created, return an empty string."
  value       = try(module.aws_anyscale_v2_private_vpc.anyscale_vpc_private_subnet_ids, [])
}

output "anyscale_v2_private_vpc_s3_bucket_id" {
  description = "Anyscale S3 Bucket ID. If a bucket was not created, return an empty string."
  value       = try(module.aws_anyscale_v2_private_vpc.anyscale_s3_bucket_id, "")
}

output "anyscale_v2_private_vpc_security_group_id" {
  description = "Anyscale Security Group ID. If a security group was not created, return an empty string."
  value       = try(module.aws_anyscale_v2_private_vpc.anyscale_security_group_id, "")
}

output "anyscale_v2_private_vpc_iam_role_arn" {
  description = "Anyscale IAM access role arn."
  value       = try(module.aws_anyscale_v2_private_vpc.anyscale_iam_role_arn, "")
}

output "anyscale_v2_private_vpc_iam_instance_role_arn" {
  description = "Anyscale IAM instance role arn."
  value       = try(module.aws_anyscale_v2_private_vpc.anyscale_iam_role_cluster_node_arn, "")
}

output "anyscale_v2_private_vpc_efs_id" {
  description = "Anyscale Elastic File System ID."
  value       = try(module.aws_anyscale_v2_private_vpc.anyscale_efs_id, "")
}
