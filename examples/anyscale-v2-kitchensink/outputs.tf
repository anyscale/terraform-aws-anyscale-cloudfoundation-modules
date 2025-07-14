# ---------------------------------------------------------------------------------------------------------------------
# Anyscale v2 Stack Kitchen Sink Example
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
    --vpc-id ${module.aws_anyscale_v2_kitchen_sink.anyscale_vpc_id} \
    --subnet-ids ${join(",", module.aws_anyscale_v2_kitchen_sink.anyscale_vpc_private_subnet_ids)} \
    --security-group-ids ${module.aws_anyscale_v2_kitchen_sink.anyscale_security_group_id} \
    --s3-bucket-id ${module.aws_anyscale_v2_kitchen_sink.anyscale_s3_bucket_id} \
    --anyscale-iam-role-id ${module.aws_anyscale_v2_kitchen_sink.anyscale_iam_role_arn} \
    --instance-iam-role-id ${module.aws_anyscale_v2_kitchen_sink.anyscale_iam_role_cluster_node_arn} \
    --efs-id ${module.aws_anyscale_v2_kitchen_sink.anyscale_efs_id} \
    --memorydb-cluster-id ${module.aws_anyscale_v2_kitchen_sink.anyscale_memorydb_cluster_id} \
    --external-id ${var.anyscale_external_id} \
    --private-network \
    --functional-verify workspace
  EOT
}
