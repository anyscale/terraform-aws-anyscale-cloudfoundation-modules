# ---------------
# Public Subnets
# ---------------

locals {
  public_subnet_count   = length(var.public_subnets) > 0 ? length(var.public_subnets) : 0
  existing_pub_rt_count = length(var.existing_public_route_table_ids) > 0 ? length(var.existing_public_route_table_ids) : 0

  public_route_table_ids = local.existing_pub_rt_count > 0 ? var.existing_public_route_table_ids : local.public_subnet_count > 0 ? aws_route_table.public[*].id : []
}

# -----------
# Subnets
# -----------
#tfsec:ignore:aws-ec2-no-public-ip-subnet:Allow public IPs by default in this subnet.
resource "aws_subnet" "public" {
  #checkov:skip=CKV_AWS_130:Allow public IPs by default in this subnet
  count = var.module_enabled && local.public_subnet_count > 0 ? local.public_subnet_count : 0

  vpc_id                  = local.vpc_id
  cidr_block              = element(concat(var.public_subnets, [""]), count.index)
  availability_zone       = local.subnet_availability_zones[count.index]
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(
    {
      Name = try(
        var.public_subnet_names[count.index],
        format("${local.vpc_name}-${var.private_subnet_suffix}-%s", lookup(local.az_id_map, local.subnet_availability_zones[count.index])),
        format("${local.vpc_name}-${var.public_subnet_suffix}-%s", local.subnet_availability_zones[count.index])
      )
    },
    var.tags
  )
}

# -----------------
# Internet Gateway
# -----------------
resource "aws_internet_gateway" "anyscale_vpc" {
  count = var.module_enabled && var.create_igw && local.public_subnet_count > 0 ? 1 : 0

  vpc_id = local.vpc_id

  tags = merge(
    { "Name" = local.vpc_name },
    var.tags
  )
}

# -------------
# Route Tables
# -------------
resource "aws_route_table" "public" {
  count = var.module_enabled && local.public_subnet_count > 0 ? 1 : 0

  vpc_id = local.vpc_id

  tags = merge(
    { "Name" = "${local.vpc_name}-${var.public_subnet_suffix}" },
    var.tags
  )
}

# -------------------------
# Route table associations
# -------------------------
resource "aws_route_table_association" "public" {
  count = var.module_enabled && local.public_subnet_count > 0 ? local.public_subnet_count : 0

  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = element(local.public_route_table_ids, count.index)
}

# -------------
# Routes
# -------------
# Public Route to IGW
resource "aws_route" "public_route_igw" {
  count = var.module_enabled && var.create_igw && local.public_subnet_count > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.anyscale_vpc[0].id

  timeouts {
    create = "5m"
  }
}
