# ---------------------------------------------------------------------------------------------------------------------
# Anyscale v2 Stack resources
# ---------------------------------------------------------------------------------------------------------------------
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
    --vpc-id ${module.aws_anyscale_v2_kms.anyscale_vpc_id} \
    --subnet-ids ${join(",", module.aws_anyscale_v2_kms.anyscale_vpc_public_subnet_ids)} \
    --security-group-ids ${module.aws_anyscale_v2_kms.anyscale_security_group_id} \
    --s3-bucket-id ${module.aws_anyscale_v2_kms.anyscale_s3_bucket_id} \
    --anyscale-iam-role-id ${module.aws_anyscale_v2_kms.anyscale_iam_role_arn} \
    --instance-iam-role-id ${module.aws_anyscale_v2_kms.anyscale_iam_role_cluster_node_arn} \
    --efs-id ${module.aws_anyscale_v2_kms.anyscale_efs_id}
  EOT
}

output "anyscale_cloud_resource_yaml" {
  description = <<-EOF
    Anyscale cloud resource YAML configuration for KMS example.
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
  bucket_name: s3://${module.aws_anyscale_v2_kms.anyscale_s3_bucket_id}
file_storage:
  file_storage_id: ${module.aws_anyscale_v2_kms.anyscale_efs_id}
aws_config:
  vpc_id: ${module.aws_anyscale_v2_kms.anyscale_vpc_id}
  subnet_ids:
    - ${join("\n    - ", module.aws_anyscale_v2_kms.anyscale_vpc_public_subnet_ids)}
  security_group_ids:
    - ${module.aws_anyscale_v2_kms.anyscale_security_group_id}
  anyscale_iam_role_id: ${module.aws_anyscale_v2_kms.anyscale_iam_role_arn}
  cluster_iam_role_id: ${module.aws_anyscale_v2_kms.anyscale_iam_role_cluster_node_arn}
EOT
}
