# -------------------------
# Elastic File System
# -------------------------
output "efs_arn" {
  description = "ARN of the Anyscale Elastic File System (EFS) resource"
  value       = try(aws_efs_file_system.anyscale_efs[0].arn, "")
}

output "efs_id" {
  description = "ID that identifies the Anyscale Elastic File System (EFS) resource"
  value       = try(aws_efs_file_system.anyscale_efs[0].id, "")
}

output "efs_dns_name" {
  description = "DNS Name for the Anyscale Elastic File System (EFS) resource"
  value       = try(aws_efs_file_system.anyscale_efs[0].dns_name, "")
}

# -------------------------
# EFS Mount Targets
# -------------------------
output "efs_mount_target_ids" {
  description = "EFS Mount Target IDs"
  value       = try(aws_efs_mount_target.anyscale_efs[*].id, [])
}

output "efs_mount_target_network_interface_ids" {
  description = "EFS mount target network interface IDs"
  value       = try(aws_efs_mount_target.anyscale_efs[*].network_interface_id, [])
}

output "efs_mount_target_availability_zone_names" {
  description = "EFS mount target availability zone names"
  value       = try(aws_efs_mount_target.anyscale_efs[*].availability_zone_name, [])
}

output "efs_mount_target_availability_zone_ids" {
  description = "EFS mount target availability zone IDs"
  value       = try(aws_efs_mount_target.anyscale_efs[*].availability_zone_id, [])
}

output "efs_mount_target_ips" {
  description = "EFS mount target IPs"
  value       = try(aws_efs_mount_target.anyscale_efs[*].ip_address, [])
}
