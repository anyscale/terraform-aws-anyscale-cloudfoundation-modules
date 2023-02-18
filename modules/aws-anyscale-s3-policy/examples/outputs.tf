# --------------
# Defaults Test
# --------------
output "s3_bucket_id_defaults" {
  description = "The ID of the anyscale resource."
  value       = module.s3_bucket_defaults.s3_bucket_id
}

output "s3_bucket_custom_policy_id" {
  description = "The ID of the anyscasle resource."
  value       = module.s3_bucket_custom_policy.s3_bucket_id
}

# ------------------
# Kitchen Sink Test
# ------------------


# -----------------
# No resource test
# -----------------
# output "test_no_resources" {
#   description = "The outputs of the no_resource resource - should all be empty"
#   value       = module.test_no_resources
# }
