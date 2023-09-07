# ---------------------------------------------------------------------------------------------------------------------
# Anyscale v2 Stack Kitchen Sink Example
# ---------------------------------------------------------------------------------------------------------------------
output "anyscale_register_command" {
  description = <<-EOF
    Anyscale register command.
    This output can be used with the Anyscale CLI to register a new Anyscale Cloud.
    You will need to replace `<CUSTOMER_DEFINED_NAME>` with a name of your choosing before running the Anyscale CLI command.
  EOF
  value       = "anyscale cloud register --provider aws \\\n--name <CUSTOMER_DEFINED_NAME> \\\n--region ${var.aws_region} \\\n--vpc-id ${module.aws_anyscale_v2_kitchen_sink.anyscale_vpc_id} \\\n--subnet-ids ${join(",", module.aws_anyscale_v2_kitchen_sink.anyscale_vpc_private_subnet_ids)} \\\n--security-group-ids ${module.aws_anyscale_v2_kitchen_sink.anyscale_security_group_id} \\\n--s3-bucket-id ${module.aws_anyscale_v2_kitchen_sink.anyscale_s3_bucket_id} \\\n--anyscale-iam-role-id ${module.aws_anyscale_v2_kitchen_sink.anyscale_iam_role_arn} \\\n--instance-iam-role-id ${module.aws_anyscale_v2_kitchen_sink.anyscale_iam_role_cluster_node_arn} \\\n--efs-id ${module.aws_anyscale_v2_kitchen_sink.anyscale_efs_id} \\\n--memorydb-cluster-id ${module.aws_anyscale_v2_kitchen_sink.anyscale_memorydb_cluster_id} \\\n--private-network"
}

output "memorydb_address_for_anyscaleservices" {
  description = "Anyscale MemoryDB Cluster Address."
  value       = try("${module.aws_anyscale_v2_kitchen_sink.anyscale_memorydb_cluster_endpoint_address}:${module.aws_anyscale_v2_kitchen_sink.anyscale_memorydb_cluster_endpoint_port}", "")
}
