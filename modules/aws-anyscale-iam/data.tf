# data "aws_iam_role" "existing_service_linked_role" {
#   role_name = "AWSServiceRoleForElasticLoadBalancing"

#   # This filter ensures we only look for service-linked roles
#   filter {
#     name   = "path"
#     values = ["/aws-service-role/elasticloadbalancing.amazonaws.com/"]
#   }
# }

data "aws_iam_roles" "elb_service_linked_roles" {
  path_prefix = "/aws-service-role/elasticloadbalancing.amazonaws.com/"
}

locals {
  create_alb_linked_role = var.module_enabled && length(data.aws_iam_roles.elb_service_linked_roles) > 0 ? false : true
}
