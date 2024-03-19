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
    --efs-id ${module.aws_anyscale_v2_kms.anyscale_efs_id} \
    --functional-verify workspace
  EOT
}
