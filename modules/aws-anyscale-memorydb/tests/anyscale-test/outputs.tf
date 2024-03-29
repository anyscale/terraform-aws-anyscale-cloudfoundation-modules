# --------------
# Defaults Test
# --------------
output "all_defaults_arn" {
  description = "The arn of the anyscale resource."
  value       = module.all_defaults.memorydb_cluster_arn
}

output "all_defaults_id" {
  description = "The ID of the anyscale resource."
  value       = module.all_defaults.memorydb_cluster_id
}

# ------------------
# Kitchen Sink Test
# ------------------
output "kitchen_sink_arn" {
  description = "The arn of the anyscale resource."
  value       = module.kitchen_sink.memorydb_cluster_arn
}

output "kitchen_sink_id" {
  description = "The ID of the anyscale resource."
  value       = module.kitchen_sink.memorydb_cluster_id
}

# -----------------
# No resource test
# -----------------
output "test_no_resources" {
  description = "The outputs of the no_resource resource - should all be empty"
  value       = module.test_no_resources
  sensitive   = true
}
