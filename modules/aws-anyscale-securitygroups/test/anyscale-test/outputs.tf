# --------------
# Defaults Test
# --------------
output "all_defaults_arn" {
  description = "The arn of the anyscale resource."
  value       = module.all_defaults.security_group_arn
}

output "all_defaults_id" {
  description = "The ID of the anyscale resource."
  value       = module.all_defaults.security_group_id
}

output "all_defaults_name" {
  description = "The name of the anyscale resource."
  value       = module.all_defaults.security_group_name
}

# ------------------
# Machine Pool Test
# ------------------
output "anyscale_amp_arn" {
  description = "The arn of the anyscale resource."
  value       = module.anyscale_amp.security_group_arn
}

output "anyscale_amp_id" {
  description = "The ID of the anyscale resource."
  value       = module.anyscale_amp.security_group_id
}

output "anyscale_amp_name" {
  description = "The name of the anyscale resource."
  value       = module.anyscale_amp.security_group_name
}
# ------------------
# Kitchen Sink Test
# ------------------
output "kitchen_sink_arn" {
  description = "The arn of the kitchen sink anyscale resource."
  value       = module.kitchen_sink.security_group_arn
}

output "kitchen_sink_id" {
  description = "The ID of the kitchen sink anyscale resource."
  value       = module.kitchen_sink.security_group_id
}

output "kitchen_sink_region" {
  description = "The region of the kitchen sink anyscale resource."
  value       = module.kitchen_sink.security_group_name
}


# -----------------
# No resource test
# -----------------
output "test_no_resources" {
  description = "The outputs of the no_resource resource - should all be empty"
  value       = module.test_no_resources
}
