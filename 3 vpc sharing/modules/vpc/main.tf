data aws_availability_zones available {
  state = "available"
}

locals {
  cidrs = cidrsubnets(var.cidr, 2, 2, 2, 2)
  private_cidrs = [
    local.cidrs[0],
    local.cidrs[1]
  ]

  public_cidrs = [
    local.cidrs[2],
    local.cidrs[3]
  ]

  vpc_name = "vpc-${var.account_name}"

  subnet_private_name = "sn-priv-${var.account_name}"
  subnet_public_name  = "sn-pub-${var.account_name}"

  igw_name = "igw-${var.account_name}"
  nat_name = "nat-${var.account_name}"

  log_group_name = "cw-vpcflowlogs-${var.account_name}"
  role_name = "iam-vpcflowlogs-${var.account_name}"
}


resource aws_vpc main {
  cidr_block       = var.cidr
  instance_tenancy = "default"

  enable_dns_hostnames = true

  tags = {
    Name = local.vpc_name
  }
}

// Private Subnet
// =======================

resource aws_subnet private {

  count = length(local.private_cidrs)

  availability_zone_id = data.aws_availability_zones.available.zone_ids[count.index]

  vpc_id     = aws_vpc.main.id
  cidr_block = local.private_cidrs[count.index]

  tags = {
    Name = "${local.subnet_private_name}-${count.index + 1}"
  }
}

resource aws_route_table private {
  count = length(local.private_cidrs)

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.subnet_private_name}-${count.index + 1}"
  }
}

resource aws_route private {
  count = length(local.private_cidrs)

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
}

resource aws_route_table_association private {
  count = length(local.private_cidrs)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}


// Public Subnet
// =======================

resource aws_internet_gateway main {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = local.igw_name
  }
}

resource aws_eip nat {
  count = length(local.public_cidrs)
  vpc   = true
}

resource aws_nat_gateway main {

  count = length(local.public_cidrs)

  depends_on = [aws_internet_gateway.main]

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${local.nat_name}-${count.index + 1}"
  }
}


resource aws_subnet public {

  count = length(local.public_cidrs)

  availability_zone_id = data.aws_availability_zones.available.zone_ids[count.index]

  vpc_id     = aws_vpc.main.id
  cidr_block = local.public_cidrs[count.index]

  tags = {
    Name = "${local.subnet_public_name}-${count.index + 1}"
  }
}

resource aws_route_table public {
  count = length(local.public_cidrs)

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.subnet_public_name}-${count.index + 1}"
  }
}

resource aws_route public {
  count = length(local.public_cidrs)

  route_table_id         = aws_route_table.public[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource aws_route_table_association public {
  count = length(local.public_cidrs)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[count.index].id
}

