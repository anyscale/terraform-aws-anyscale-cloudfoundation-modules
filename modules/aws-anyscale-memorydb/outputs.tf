# -------------------------
# MemoryDB Cluster
# -------------------------
output "memorydb_cluster_arn" {
  description = "MemoryDB Cluster ARN"
  value       = try(aws_memorydb_cluster.anyscale_memorydb[0].arn, "")
}

output "memorydb_cluster_id" {
  description = "MemoryDB Cluster Name"
  value       = try(aws_memorydb_cluster.anyscale_memorydb[0].id, "")
}

output "memorydb_cluster_endpoint_address" {
  description = "DNS hostname of the cluster configuration endpoint"
  value       = try(aws_memorydb_cluster.anyscale_memorydb[0].cluster_endpoint[0].address, "")
}

output "memorydb_cluster_endpoint_port" {
  description = "Port number that the cluster configuration endpoint is listening on"
  value       = try(aws_memorydb_cluster.anyscale_memorydb[0].cluster_endpoint[0].port, "")
}

output "memorydb_cluster_shards" {
  description = "Set of shards in this cluster"
  value       = try(aws_memorydb_cluster.anyscale_memorydb[0].shards, [])
}

# -------------------------
# MemoryDB Parameter Group
# -------------------------
output "memorydb_parameter_group_arn" {
  description = "The ARN of the MemoryDB parameter group"
  value       = try(aws_memorydb_parameter_group.anyscale_memorydb[0].arn, "")
}

output "memorydb_parameter_group_id" {
  description = "Name of the MemoryDB parameter group"
  value       = try(aws_memorydb_parameter_group.anyscale_memorydb[0].id, "")
}

# -------------------------
# MemoryDB ACL
# -------------------------
output "memorydb_acl_arn" {
  description = "The ARN of the MemoryDB ACL"
  value       = try(aws_memorydb_acl.anyscale_memorydb[0].arn, "")
}

output "memorydb_acl_id" {
  description = "Name of the MemoryDB ACL"
  value       = try(aws_memorydb_acl.anyscale_memorydb[0].id, "")
}

# -------------------------
# MemoryDB Subnet Group
# -------------------------
output "subnet_group_arn" {
  description = "ARN of the MemoryDB subnet group"
  value       = try(aws_memorydb_subnet_group.anyscale_memorydb[0].arn, "")
}

output "memorydb_subnet_group_id" {
  description = "Name of the MemoryDB subnet group"
  value       = try(aws_memorydb_subnet_group.anyscale_memorydb[0].id, "")
}

output "subnet_group_vpc_id" {
  description = "The VPC in which the MemoryDB subnet group exists"
  value       = try(aws_memorydb_subnet_group.anyscale_memorydb[0].vpc_id, "")
}

# -------------------------
# MemoryDB Users
# -------------------------
output "users" {
  description = "Map of attributes for the users created"
  value       = aws_memorydb_user.anyscale_memorydb
  sensitive   = true
}
