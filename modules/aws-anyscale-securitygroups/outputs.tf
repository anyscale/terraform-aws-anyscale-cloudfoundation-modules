output "security_group_arn" {
  description = "The ARN of the security group"
  value       = try(aws_security_group.anyscale_security_group[0].arn, "")
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = try(aws_security_group.anyscale_security_group[0].id, "")
}

output "security_group_name" {
  description = "The name of the security group"
  value       = try(aws_security_group.anyscale_security_group[0].name, "")
}

output "machine_pool_security_group_id" {
  description = "The ID of the machine pool security group"
  value       = try(aws_security_group.machine_pool[0].id, "")
}

output "machine_pool_security_group_arn" {
  description = "The ARN of the machine pool security group"
  value       = try(aws_security_group.machine_pool[0].arn, "")
}

output "machine_pool_security_group_name" {
  description = "The name of the machine pool security group"
  value       = try(aws_security_group.machine_pool[0].name, "")
}
