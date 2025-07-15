# --------------
# Defaults Test
# --------------
output "all_defaults_arn" {
  description = "The arn of the anyscale resource."
  value       = module.all_defaults.s3_bucket_arn
}

output "all_defaults_id" {
  description = "The ID of the anyscale resource."
  value       = module.all_defaults.s3_bucket_id
}

output "all_defaults_region" {
  description = "The region of the anyscale resource."
  value       = module.all_defaults.s3_bucket_region
}

# ------------------
# Kitchen Sink Test
# ------------------
output "kitchen_sink_arn" {
  description = "The arn of the kitchen sink anyscale resource."
  value       = module.kitchen_sink.s3_bucket_arn
}

output "kitchen_sink_id" {
  description = "The ID of the kitchen sink anyscale resource."
  value       = module.kitchen_sink.s3_bucket_id
}

output "kitchen_sink_region" {
  description = "The region of the kitchen sink anyscale resource."
  value       = module.kitchen_sink.s3_bucket_region
}


# -----------------
# No resource test
# -----------------
output "test_no_resources" {
  description = "The outputs of the no_resource resource - should all be empty"
  value       = module.test_no_resources
}
