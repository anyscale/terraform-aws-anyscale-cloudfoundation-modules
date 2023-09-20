# ---------------------------------------------------------------------------------------------------------------------
# Anyscale v2 Stack with existing VPC
# ---------------------------------------------------------------------------------------------------------------------
output "anyscale_v2_s3_bucket_id" {
  description = "Anyscale S3 Bucket ID. If a bucket was not created, return an empty string."
  value       = try(module.aws_anyscale_v2_existing_vpc.anyscale_s3_bucket_id, "")
}

output "anyscale_v2_security_group_id" {
  description = "Anyscale Security Group ID. If a security group was not created, return an empty string."
  value       = try(module.aws_anyscale_v2_existing_vpc.anyscale_security_group_id, "")
}

output "anyscale_v2_iam_role_arn" {
  description = "Anyscale IAM access role arn."
  value       = try(module.aws_anyscale_v2_existing_vpc.anyscale_iam_role_arn, "")
}

output "anyscale_v2_iam_instance_role_arn" {
  description = "Anyscale IAM instance role arn."
  value       = try(module.aws_anyscale_v2_existing_vpc.anyscale_iam_role_cluster_node_arn, "")
}

output "anyscale_v2_efs_id" {
  description = "Anyscale Elastic File System ID."
  value       = try(module.aws_anyscale_v2_existing_vpc.anyscale_efs_id, "")
}

output "anyscale_register_command" {
  description = <<-EOF
    Anyscale register command.
    This output can be used with the Anyscale CLI to register a new Anyscale Cloud.
    You will need to replace `<CUSTOMER_DEFINED_NAME>` with a name of your choosing before running the Anyscale CLI command.
  EOF
  value       = <<-EOT
    anyscale cloud register --provider aws \
    --name <CUSTOMER_DEFINED_NAME> \
    --region ${var.aws_region} \
    --vpc-id ${var.existing_vpc_id} \
    --subnet-ids ${join(",", var.existing_subnet_ids)} \
    --security-group-ids ${module.aws_anyscale_v2_existing_vpc.anyscale_security_group_id} \
    --s3-bucket-id ${module.aws_anyscale_v2_existing_vpc.anyscale_s3_bucket_id} \
    --anyscale-iam-role-id ${module.aws_anyscale_v2_existing_vpc.anyscale_iam_role_arn} \
    --instance-iam-role-id ${module.aws_anyscale_v2_existing_vpc.anyscale_iam_role_cluster_node_arn} \
    --efs-id ${module.aws_anyscale_v2_existing_vpc.anyscale_efs_id}
  EOT
}
