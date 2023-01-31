locals {
  gateway_endpoints_enabled = var.module_enabled && length(var.gateway_vpc_endpoints) > 0 && (local.public_subnet_count > 0 || local.private_subnet_count > 0) ? true : false
  route_table_associations_list = flatten([for k, v in var.gateway_vpc_endpoints : [
    for i, route_id in local.all_route_table_ids : {
      key            = "${k}[${i}]"
      gateway        = k
      route_table_id = route_id
    }
  ]])
  route_table_associations_map = { for v in local.route_table_associations_list : v.key => v }
}

# Gateway Endpoints
data "aws_vpc_endpoint_service" "gateway_endpoints" {
  for_each     = local.gateway_endpoints_enabled ? var.gateway_vpc_endpoints : {}
  service      = var.gateway_vpc_endpoints[each.key].name
  service_type = "Gateway"
}

resource "aws_vpc_endpoint" "gateway_endpoint" {
  for_each          = local.gateway_endpoints_enabled ? data.aws_vpc_endpoint_service.gateway_endpoints : {}
  service_name      = data.aws_vpc_endpoint_service.gateway_endpoints[each.key].service_name
  policy            = var.gateway_vpc_endpoints[each.key].policy
  vpc_endpoint_type = data.aws_vpc_endpoint_service.gateway_endpoints[each.key].service_type
  vpc_id            = local.vpc_id

  tags = merge(
    {
      Name = "${local.vpc_name}-gateway-endpoint-${data.aws_vpc_endpoint_service.gateway_endpoints[each.key].service_name}"
    },
    var.tags
  )
}

resource "aws_vpc_endpoint_route_table_association" "gateway_endpoint" {
  for_each = local.gateway_endpoints_enabled ? local.route_table_associations_map : {}

  route_table_id  = each.value.route_table_id
  vpc_endpoint_id = aws_vpc_endpoint.gateway_endpoint[each.value.gateway].id
}
