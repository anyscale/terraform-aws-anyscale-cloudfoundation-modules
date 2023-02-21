# ---------------------------------------------------------------------------------------------------------------------
# Anyscale v1 Stack resources with minimal parameters
# ---------------------------------------------------------------------------------------------------------------------
output "anyscale_v1_vpc_id" {
  description = "Anyscale VPC ID. If there was not one created, return the one that was used during other resource creation."
  value       = try(module.aws_anyscale_v1.anyscale_vpc_id, "")
}

output "anyscale_v1_vpc_public_subnet_ids" {
  description = "Anyscale VPC Public Subnet IDs. If there were none created, return an empty string."
  value       = try(module.aws_anyscale_v1.anyscale_vpc_public_subnet_ids, [])
}
output "anyscale_v1_vpc_private_subnet_ids" {
  description = "Anyscale VPC Private Subnet IDs. If there were none created, return an empty string."
  value       = try(module.aws_anyscale_v1.anyscale_vpc_private_subnet_ids, [])
}

output "anyscale_v1_s3_bucket_id" {
  description = "Anyscale S3 Bucket ID. If a bucket was not created, return an empty string."
  value       = try(module.aws_anyscale_v1.anyscale_s3_bucket_id, "")
}

output "anyscale_v1_security_group_id" {
  description = "Anyscale Security Group ID. If a security group was not created, return an empty string."
  value       = try(module.aws_anyscale_v1.anyscale_security_group_id, "")
}

output "anyscale_v1_iam_role_arn" {
  description = "Anyscale IAM access role arn."
  value       = try(module.aws_anyscale_v1.anyscale_iam_role_arn, "")
}

output "anyscale_v1_iam_instance_role_arn" {
  description = "Anyscale IAM instance role arn."
  value       = try(module.aws_anyscale_v1.anyscale_iam_role_cluster_node_arn, "")
}

output "anyscale_v1_efs_id" {
  description = "Anyscale Elastic File System ID."
  value       = try(module.aws_anyscale_v1.anyscale_efs_id, "")
}

# output "anyscale_v1_efs_mount_target_ids" {
#   description = "Anyscale Elastic File System mount target IDs. If EFS mount targets were not created, return an empty list."
#   value       = try(module.aws_anyscale_v1.anyscale_efs_mount_target_ids, [])
# }

# ---------------------------------------------------------------------------------------------------------------------
# Anyscale v1 Stack with existing VPC
# ---------------------------------------------------------------------------------------------------------------------
output "anyscale_v1_existing_vpc_s3_bucket_id" {
  description = "Anyscale S3 Bucket ID. If a bucket was not created, return an empty string."
  value       = try(module.aws_anyscale_v1_existing_vpc.anyscale_s3_bucket_id, "")
}

output "anyscale_v1_existing_vpc_security_group_id" {
  description = "Anyscale Security Group ID. If a security group was not created, return an empty string."
  value       = try(module.aws_anyscale_v1_existing_vpc.anyscale_security_group_id, "")
}

output "anyscale_v1_existing_vpc_iam_role_arn" {
  description = "Anyscale IAM access role arn."
  value       = try(module.aws_anyscale_v1_existing_vpc.anyscale_iam_role_arn, "")
}

output "anyscale_v1_existing_vpc_iam_instance_role_arn" {
  description = "Anyscale IAM instance role arn."
  value       = try(module.aws_anyscale_v1_existing_vpc.anyscale_iam_role_cluster_node_arn, "")
}

output "anyscale_v1_existing_vpc_efs_id" {
  description = "Anyscale Elastic File System ID."
  value       = try(module.aws_anyscale_v1_existing_vpc.anyscale_efs_id, "")
}

# output "anyscale_v1_existing_vpc_efs_mount_target_ids" {
#   description = "Anyscale Elastic File System mount target IDs. If EFS mount targets were not created, return an empty list."
#   value       = try(module.aws_anyscale_v1_existing_vpc.anyscale_efs_mount_target_ids, [])
# }
