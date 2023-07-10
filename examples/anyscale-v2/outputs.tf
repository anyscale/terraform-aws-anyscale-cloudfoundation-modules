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


output "anyscale_register_command" {
  description = <<-EOF
    Anyscale register command.
    This output can be used with the Anyscale CLI to register a new Anyscale Cloud.
    You need to replace `<CUSTOMER_DEFINED_NAME>` with a name of your choosing.
  EOF
  value       = "anyscale cloud register --provider aws \\\n--name <CUSTOMER_DEFINED_NAME> \\\n--region ${var.aws_region} \\\n--vpc-id ${module.aws_anyscale_v2.anyscale_vpc_id} \\\n--subnet-ids ${join(",", module.aws_anyscale_v2.anyscale_vpc_public_subnet_ids)} \\\n--security-group-ids ${module.aws_anyscale_v2.anyscale_security_group_id} \\\n--s3-bucket-id ${module.aws_anyscale_v2.anyscale_s3_bucket_id} \\\n--anyscale-iam-role-id ${module.aws_anyscale_v2.anyscale_iam_role_arn} \\\n--instance-iam-role-id ${module.aws_anyscale_v2.anyscale_iam_role_cluster_node_arn} \\\n--efs-id ${module.aws_anyscale_v2.anyscale_efs_id}"
}
