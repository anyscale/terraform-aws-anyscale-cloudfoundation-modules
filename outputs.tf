# -------------------------------
# VPC Resource Outputs
# -------------------------------
output "anyscale_vpc_id" {
  description = "Anyscale VPC ID. If there was not one created, return the one that was used during other resource creation."
  value       = try(module.aws_anyscale_vpc.vpc_id, var.existing_vpc_id, "")
}

output "anyscale_vpc_public_routetable_ids" {
  description = "Anyscale VPC Public Route Table IDs. If none were created, return an empty string."
  value       = try(module.aws_anyscale_vpc.public_route_table_ids, [])
}
output "anyscale_vpc_public_subnet_ids" {
  description = "Anyscale VPC Public Subnet IDs. If there were none created, return an empty string."
  value       = try(module.aws_anyscale_vpc.public_subnet_ids, [])
}
output "anyscale_vpc_private_routetable_ids" {
  description = "Anyscale VPC Private Route Table IDs. If none were created, return an empty string."
  value       = try(module.aws_anyscale_vpc.private_route_table_ids, [])
}
output "anyscale_vpc_private_subnet_ids" {
  description = "Anyscale VPC Private Subnet IDs. If there were none created, return an empty string."
  value       = try(module.aws_anyscale_vpc.private_subnet_ids, [])
}

# -------------------------------
# S3 Resource Outputs
# -------------------------------
output "anyscale_s3_bucket_id" {
  description = "Anyscale S3 Bucket ID. If a bucket was not created, return an empty string."
  value       = try(module.aws_anyscale_s3.s3_bucket_id, "")
}

# -------------------------------
# Security Group Outputs
# -------------------------------
output "anyscale_security_group_id" {
  description = "Anyscale Security Group ID. If a security group was not created, return an empty string."
  value       = try(module.aws_anyscale_securitygroup_self.security_group_id, "")
}

# -------------------------------
# IAM Resource Outputs
# -------------------------------
output "anyscale_iam_role_arn" {
  description = "Anyscale IAM access role arn."
  value       = try(module.aws_anyscale_iam.iam_anyscale_access_role_arn, "")
}

output "anyscale_iam_role_cluster_node_arn" {
  description = "Anyscale IAM cluster node role arn."
  value       = try(module.aws_anyscale_iam.iam_cluster_node_role_arn, "")
}

output "anyscale_iam_instance_profile_role_arn" {
  description = "Anyscale IAM instance profile role arn."
  value       = try(module.aws_anyscale_iam.iam_cluster_node_instance_profile_role_arn, "")
}

# -------------------------------
# Elastic File System Outputs
# -------------------------------
output "anyscale_efs_id" {
  description = "Anyscale Elastic File System ID. If an EFS resource was not created, return an empty string."
  value       = try(module.aws_anyscale_efs.efs_id, "")
}

output "anyscale_efs_arn" {
  description = "Anyscale Elastic File System ARN. If an EFS resource was not created, return an empty string."
  value       = try(module.aws_anyscale_efs.efs_arn, "")
}

output "anyscale_efs_mount_target_ids" {
  description = "Anyscale Elastic File System mount target IDs. If EFS mount targets were not created, return an empty list."
  value       = try(module.aws_anyscale_efs.efs_mount_target_ids, [])
}

# -------------------------------
# MemoryDB Outputs
# -------------------------------
output "anyscale_memorydb_cluster_id" {
  description = "Anyscale MemoryDB Cluster ID. If a MemoryDB cluster was not created, return an empty string."
  value       = try(module.aws_anyscale_memorydb.memorydb_cluster_id, "")
}

output "anyscale_memorydb_cluster_arn" {
  description = "Anyscale MemoryDB Cluster ARN. If a MemoryDB cluster was not created, return an empty string."
  value       = try(module.aws_anyscale_memorydb.memorydb_cluster_arn, "")
}

output "anyscale_memorydb_cluster_endpoint_address" {
  description = "Anyscale MemoryDB Cluster Endpoint Address. If a MemoryDB cluster was not created, return an empty string."
  value       = try(module.aws_anyscale_memorydb.memorydb_cluster_endpoint_address, "")
}

output "anyscale_memorydb_cluster_endpoint_port" {
  description = "Anyscale MemoryDB Cluster Endpoint Port. If a MemoryDB cluster was not created, return an empty string."
  value       = try(module.aws_anyscale_memorydb.memorydb_cluster_endpoint_port, "")
}
