# --------------
# Defaults Test
# --------------
output "all_defaults_name" {
  description = "The name of the anyscale resource."
  value       = module.all_defaults.eks_cluster_name
}

output "all_defaults_arn" {
  description = "The arn of the anyscale resource."
  value       = module.all_defaults.eks_cluster_arn
}

output "all_defaults_id" {
  description = "The ID of the anyscale resource."
  value       = module.all_defaults.eks_cluster_id
}

output "all_defaults_resources" {
  description = "The resources of the All Defaults test"
  value       = module.all_defaults
}

# ------------------
# Kitchen Sink Test
# ------------------
output "kitchen_sink_resources" {
  description = "The resources of the Kitchen Sink test"
  value       = module.kitchen_sink
}

# ------------------
# EKS Standard Test
# ------------------
output "eks_cluster_standard_resources" {
  description = "The resources of the EKS Standard Test"
  value       = module.eks_cluster_standard
}

# -----------------
# No resource test
# -----------------
output "test_no_resources" {
  description = "The outputs of the no_resource resource - should all be empty"
  value       = module.test_no_resources
}
