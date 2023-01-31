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

output "anyscale_v1_existing_vpc_efs_mount_target_ids" {
  description = "Anyscale Elastic File System mount target IDs. If EFS mount targets were not created, return an empty list."
  value       = try(module.aws_anyscale_v1_existing_vpc.anyscale_efs_mount_target_ids, [])
}

# ---------------------------------------------------------------------------------------------------------------------
# Anyscale v2 Stack Test
# ---------------------------------------------------------------------------------------------------------------------
# output "all_defaults_arn" {
#   description = "The arn of the anyscale resource."
#   value       = module.all_defaults.efs_arn
# }

# output "all_defaults_id" {
#   description = "The ID of the anyscale resource."
#   value       = module.all_defaults.efs_id
# }


# -----------------
# No resource test
# -----------------
# output "test_no_resources" {
#   description = "The outputs of the no_resource resource - should all be empty"
#   value       = module.test_no_resources
# }
