# -----------------
# All defaults outputs
# -----------------
output "all_defaults_arn" {
  description = "The arn of the anyscale role."
  value       = module.all_defaults.iam_anyscale_access_role_arn
}

output "node_cluster_role_arn" {
  description = "The arn of the node cluster role"
  value       = module.iam_cluster_node_instance_profile.iam_cluster_node_instance_profile_role_arn
}

# -----------------
# Secrets Manager Test
# -----------------
output "secretsmanager_role_arn" {
  description = "The arn of the secretsmanager role"
  value       = module.iam_secretsmanager_instance_profile.iam_cluster_node_instance_profile_role_arn
}

# -----------------
# Kitchen Sink Test
# -----------------
output "kitchen_sink_anyscale_role_arn" {
  description = "The arn of the kitchen sink anyscale role"
  value       = module.kitchen_sink.iam_anyscale_access_role_arn
}
output "kitchen_sink_anyscale_role_name" {
  description = "The name of the kitchen sink anyscale role"
  value       = module.kitchen_sink.iam_anyscale_access_role_name
}
output "kitchen_sink_anyscale_role_path" {
  description = "The path of the kitchen sink anyscale role"
  value       = module.kitchen_sink.iam_anyscale_access_role_path
}
output "kitchen_sink_steadystate_policy_arn" {
  description = "The arn of kitchen sink anyscale steady state IAM policy"
  value       = module.kitchen_sink.anyscale_steadystate_policy_arn
}
output "kitchen_sink_steadystate_policy_name" {
  description = "The name of the kitchen sink anyscale steady state IAM policy"
  value       = module.kitchen_sink.anyscale_steadystate_policy_name
}
output "kitchen_sink_steadystate_policy_path" {
  description = "The path of the kitchen sink anyscale steady state IAM policy"
  value       = module.kitchen_sink.anyscale_steadystate_policy_path
}
output "kitchen_sink_servicesv2_policy_arn" {
  description = "The arn of the kitchen sink anyscale servicesv2 IAM policy"
  value       = module.kitchen_sink.anyscale_servicesv2_policy_arn
}
output "kitchen_sink_servicesv2_policy_name" {
  description = "The name of the kitchen sink anyscale servicesv2 IAM policy"
  value       = module.kitchen_sink.anyscale_servicesv2_policy_name
}
output "kitchen_sink_servicesv2_policy_path" {
  description = "The path of the kitchen sink anyscale servicesv2 IAM policy"
  value       = module.kitchen_sink.anyscale_servicesv2_policy_path
}

output "kitchen_sink_access_custom_policy_arn" {
  description = "The arn of kitchen sink anyscale custom IAM policy"
  value       = module.kitchen_sink.anyscale_iam_custom_policy_arn
}
output "kitchen_sink_access_custom_policy_name" {
  description = "The name of the kitchen sink anyscale custom IAM policy"
  value       = module.kitchen_sink.anyscale_iam_custom_policy_name
}
output "kitchen_sink_access_custom_policy_path" {
  description = "The path of the kitchen sink anyscale custom IAM policy"
  value       = module.kitchen_sink.anyscale_iam_custom_policy_path
}

# Cluster Node Outputs
output "kitchen_sink_cluster_node_role_arn" {
  description = "The patch of the kitchen sink cluster node role"
  value       = module.kitchen_sink.iam_cluster_node_instance_profile_role_arn
}
output "kitchen_sink_cluster_node_role_name" {
  description = "The name of the kitchen sink cluster node role"
  value       = module.kitchen_sink.iam_cluster_node_instance_profile_name
}
output "kitchen_sink_cluster_node_instance_profile_id" {
  description = "The instance profile id of the kitchen sink cluster nod role"
  value       = module.kitchen_sink.iam_cluster_node_instance_profile_id
}
output "kitchen_sink_cluster_node_profile_path" {
  description = "The path of the kitchen sink cluster node role"
  value       = module.kitchen_sink.iam_cluster_node_instance_profile_path
}

output "kitchen_sink_cluster_node_custom_policy_arn" {
  description = "The arn of kitchen sink anyscale custom IAM policy"
  value       = module.kitchen_sink.anyscale_cluster_node_custom_policy_arn
}
output "kitchen_sink_cluster_node_custom_policy_name" {
  description = "The name of the kitchen sink anyscale custom IAM policy"
  value       = module.kitchen_sink.anyscale_cluster_node_custom_policy_name
}
output "kitchen_sink_cluster_node_custom_policy_path" {
  description = "The path of the kitchen sink anyscale custom IAM policy"
  value       = module.kitchen_sink.anyscale_cluster_node_custom_policy_path
}

output "kitchen_sink_iam_s3_policy_arn" {
  description = "The arn of kitchen sink anyscale IAM S3 policy"
  value       = module.kitchen_sink.anyscale_iam_s3_policy_arn
}
output "kitchen_sink_iam_s3_policy_name" {
  description = "The name of the kitchen sink anyscale IAM S3 policy"
  value       = module.kitchen_sink.anyscale_iam_s3_policy_name
}
output "kitchen_sink_iam_s3_policy_path" {
  description = "The path of the kitchen sink anyscale IAM S3 policy"
  value       = module.kitchen_sink.anyscale_iam_s3_policy_path
}

# -----------------
# No resource test
# -----------------
output "test_no_resources" {
  description = "The outputs of the no_resource resource - should be empty"
  value       = module.test_no_resources
}
