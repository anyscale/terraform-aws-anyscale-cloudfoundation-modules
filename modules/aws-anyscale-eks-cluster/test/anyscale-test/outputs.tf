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

# ------------------
# Kitchen Sink Test
# ------------------
output "kitchen_sink_arn" {
  description = "The arn of the anyscale resource."
  value       = module.kitchen_sink.eks_cluster_arn
}

output "kitchen_sink_id" {
  description = "The ID of the anyscale resource."
  value       = module.kitchen_sink.eks_cluster_id
}

output "kitchen_sink_oidc_arn" {
  description = "The OIDC issuer of the anyscale resource."
  value       = module.kitchen_sink.eks_cluster_oidc_provider_arn
}

output "kitchen_sink_oidc_url" {
  description = "The OIDC issuer of the anyscale resource."
  value       = module.kitchen_sink.eks_cluster_oidc_provider_url
}

output "kitchen_sink_resources" {
  description = "The resources of the anyscale resource."
  value       = module.kitchen_sink
}

# -----------------
# No resource test
# -----------------
output "test_no_resources" {
  description = "The outputs of the no_resource resource - should all be empty"
  value       = module.test_no_resources
}
