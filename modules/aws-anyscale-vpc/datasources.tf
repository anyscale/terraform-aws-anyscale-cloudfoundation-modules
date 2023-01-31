data "aws_availability_zones" "default" {
  count = var.module_enabled ? 1 : 0

  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}
