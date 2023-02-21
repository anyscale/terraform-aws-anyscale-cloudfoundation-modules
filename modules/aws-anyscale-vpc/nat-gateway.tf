# ---------------------
# NAT Gateway Creation
# ---------------------
locals {
  nat_gateway_count = var.create_ngw && local.private_subnet_count > 0 ? min(local.subnet_az_count, var.max_nat_gateway_count) : 0
}

# --------------------
# Elastic IPs for NAT
# --------------------
resource "aws_eip" "nat_gateway" {
  count = var.module_enabled ? local.nat_gateway_count : 0
  vpc   = true

  tags = merge(
    {
      "Name" = format(
        "${local.vpc_name}-%s",
        local.subnet_availability_zones[count.index]
      )
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ------------
# NAT Gateway
# ------------
resource "aws_nat_gateway" "nat_gateway" {
  count = var.module_enabled ? local.nat_gateway_count : 0

  allocation_id = element(aws_eip.nat_gateway[*].id, count.index)
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    {
      "Name" = format(
        "${local.vpc_name}-%s",
        local.subnet_availability_zones[count.index],
      )
    },
    var.tags
  )

  depends_on = [aws_internet_gateway.anyscale_vpc]
}

# -----------------------
# Routes to NAT Gateways
# -----------------------
resource "aws_route" "private_route_ngw" {
  count = var.module_enabled ? local.nat_gateway_count : 0

  route_table_id         = element(aws_route_table.private[*].id, count.index)
  destination_cidr_block = var.nat_gateway_destination_cidr_block
  nat_gateway_id         = element(aws_nat_gateway.nat_gateway[*].id, count.index)

  timeouts {
    create = "5m"
  }
}
