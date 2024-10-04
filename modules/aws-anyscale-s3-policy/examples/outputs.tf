# --------------
# Defaults Test
# --------------
output "all_defaults_s3_bucket" {
  description = "The ID of the anyscasle resource."
  value       = module.s3_bucket_all_defaults.s3_bucket_id
}

# ------------------
# Kitchen Sink Test
# ------------------
output "kitchen_sink_s3_bucket" {
  description = "The ID of the anyscasle resource."
  value       = module.s3_bucket_kitchen_sink.s3_bucket_id
}

# -----------------
# No resource test
# -----------------
# output "test_no_resources" {
#   description = "The outputs of the no_resource resource - should all be empty"
#   value       = module.test_no_resources
# }
