# ----------------
# Private Subnets
# ----------------

locals {
  private_subnet_count    = length(var.private_subnets) > 0 ? length(var.private_subnets) : 0
  private_route_table_ids = local.private_subnet_count > 0 ? aws_route_table.private[*].id : []
}

# ----------------
# Subnets
# ----------------
resource "aws_subnet" "private" {
  count = var.module_enabled && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  vpc_id            = local.vpc_id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = local.subnet_availability_zones[count.index]

  tags = merge(
    {
      Name = try(
        var.private_subnet_names[count.index],
        format("${local.vpc_name}-${var.private_subnet_suffix}-%s", lookup(local.az_id_map, local.subnet_availability_zones[count.index])),
        format("${local.vpc_name}-${var.private_subnet_suffix}-%s", local.subnet_availability_zones[count.index])
      )
    },
    var.tags
  )
}

# ---------------------
# Route tables
# ---------------------

# There are as many routing tables as the number of NAT gateways
resource "aws_route_table" "private" {
  count = var.module_enabled && local.private_subnet_count > 0 ? local.private_subnet_count : 0

  vpc_id = local.vpc_id

  tags = merge(
    {
      Name = try(
        var.private_subnet_names[count.index],
        format("${local.vpc_name}-${var.private_subnet_suffix}-%s", lookup(local.az_id_map, local.subnet_availability_zones[count.index])),
        format("${local.vpc_name}-${var.private_subnet_suffix}-%s", local.subnet_availability_zones[count.index])
      )
    },
    var.tags
  )
}

# -------------------------
# Route table associations
# -------------------------
resource "aws_route_table_association" "private" {
  count = var.module_enabled && local.private_subnet_count > 0 ? local.private_subnet_count : 0

  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = element(local.private_route_table_ids, count.index)
}
