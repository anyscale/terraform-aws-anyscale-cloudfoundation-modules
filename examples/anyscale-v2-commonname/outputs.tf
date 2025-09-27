# ---------------------------------------------------------------------------------------------------------------------
# Anyscale v2 Stack resources with common name
# ---------------------------------------------------------------------------------------------------------------------
output "anyscale_v2_vpc_id" {
  description = "Anyscale VPC ID. If there was not one created, return the one that was used during other resource creation."
  value       = try(module.aws_anyscale_v2_common_name.anyscale_vpc_id, "")
}

output "anyscale_v2_public_routetable_ids" {
  description = "Anyscale VPC Public Route Table IDs. If none were created, return an empty string."
  value       = try(module.aws_anyscale_v2_common_name.anyscale_vpc_public_routetable_ids, [])
}
output "anyscale_v2_public_subnet_ids" {
  description = "Anyscale VPC Public Subnet IDs. If there were none created, return an empty string."
  value       = try(module.aws_anyscale_v2_common_name.anyscale_vpc_public_subnet_ids, [])
}
output "anyscale_v2_private_routetable_ids" {
  description = "Anyscale VPC Private Route Table IDs. If none were created, return an empty string."
  value       = try(module.aws_anyscale_v2_common_name.anyscale_vpc_private_routetable_ids, [])
}
output "anyscale_v2_private_subnet_ids" {
  description = "Anyscale VPC Private Subnet IDs. If there were none created, return an empty string."
  value       = try(module.aws_anyscale_v2_common_name.anyscale_vpc_private_subnet_ids, [])
}

output "anyscale_v2_s3_bucket_id" {
  description = "Anyscale S3 Bucket ID. If a bucket was not created, return an empty string."
  value       = try(module.aws_anyscale_v2_common_name.anyscale_s3_bucket_id, "")
}

output "anyscale_v2_security_group_id" {
  description = "Anyscale Security Group ID. If a security group was not created, return an empty string."
  value       = try(module.aws_anyscale_v2_common_name.anyscale_security_group_id, "")
}

output "anyscale_v2_iam_role_arn" {
  description = "Anyscale IAM access role arn."
  value       = try(module.aws_anyscale_v2_common_name.anyscale_iam_role_arn, "")
}

output "anyscale_v2_iam_instance_role_arn" {
  description = "Anyscale IAM instance role arn."
  value       = try(module.aws_anyscale_v2_common_name.anyscale_iam_role_cluster_node_arn, "")
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
    --vpc-id ${module.aws_anyscale_v2_common_name.anyscale_vpc_id} \
    --subnet-ids ${join(",", module.aws_anyscale_v2_common_name.anyscale_vpc_public_subnet_ids)} \
    --security-group-ids ${module.aws_anyscale_v2_common_name.anyscale_security_group_id} \
    --s3-bucket-id ${module.aws_anyscale_v2_common_name.anyscale_s3_bucket_id} \
    --anyscale-iam-role-id ${module.aws_anyscale_v2_common_name.anyscale_iam_role_arn} \
    --instance-iam-role-id ${module.aws_anyscale_v2_common_name.anyscale_iam_role_cluster_node_arn} \
    --external-id ${module.aws_anyscale_v2_common_name.anyscale_iam_role_external_id} \
    --functional-verify workspace
  EOT
}

output "anyscale_cloud_resource_yaml" {
  description = <<-EOF
    Anyscale cloud resource YAML configuration for common name example.
    This output can be saved to a file and used with `anyscale cloud resource create` command.
    The name is auto-generated as vm-aws-$${var.aws_region} but can be updated in the YAML file if needed.
  EOF
  value = <<-EOT
name: vm-aws-${var.aws_region}
provider: AWS
compute_stack: VM
region: ${var.aws_region}
networking_mode: PUBLIC
object_storage:
  bucket_name: s3://${module.aws_anyscale_v2_common_name.anyscale_s3_bucket_id}
aws_config:
  vpc_id: ${module.aws_anyscale_v2_common_name.anyscale_vpc_id}
  subnet_ids:
    - ${join("\n    - ", module.aws_anyscale_v2_common_name.anyscale_vpc_public_subnet_ids)}
  security_group_ids:
    - ${module.aws_anyscale_v2_common_name.anyscale_security_group_id}
  anyscale_iam_role_id: ${module.aws_anyscale_v2_common_name.anyscale_iam_role_arn}
  cluster_iam_role_id: ${module.aws_anyscale_v2_common_name.anyscale_iam_role_cluster_node_arn}
EOT
}
