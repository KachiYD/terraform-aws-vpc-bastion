locals {
  selected_azs = slice(data.aws_availability_zones.available.names, 0, 2)

  public_subnets = {
    for key, config in var.subnet_config : key => config if config.public
  }

  private_subnets = {
    for key, config in var.subnet_config : key => config if !config.public
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "this" {
  cidr_block = var.vpc_config.cidr_block

  tags = {
    Name = var.vpc_config.name
  }
}

resource "aws_subnet" "this" {
  vpc_id            = aws_vpc.this.id
  for_each          = var.subnet_config
  availability_zone = each.value.az
  cidr_block        = each.value.cidr_block

  tags = {
    Name   = each.key
    Access = each.value.public ? "Public" : "Private"
  }

  lifecycle {
    precondition {
      condition     = contains(local.selected_azs, each.value.az)
      error_message = <<-EOT
      The AZ "${each.value.az}" provided for the subnet "${each.key}" is invalid.

      The following (2) AZs will be used for this configuration:
      [${join(", ", local.selected_azs)}]
      EOT
    }
  }
}

resource "aws_internet_gateway" "this" {
  count = length(local.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "Main IGW"
  }
}

resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.this.id
  count = length(local.public_subnets) > 0 ? 1 : 0

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this[0].id
  }

  tags = {
    Name = "Public RTB"
  }
}

resource "aws_route_table_association" "public" {
  for_each = local.public_subnets

  subnet_id = aws_subnet.this[each.key].id

  route_table_id = aws_route_table.public_rtb[0].id
}

resource "aws_route_table" "private_rtb" {
  vpc_id = aws_vpc.this.id
  count = length(local.private_subnets) > 0 ? 1 : 0

  tags = {
    Name = "Private RTB"
  }
}

resource "aws_route_table_association" "private" {
  for_each = local.private_subnets

  subnet_id = aws_subnet.this[each.key].id

  route_table_id = aws_route_table.private_rtb[0].id
}

resource "aws_eip" "elastic_ip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.elastic_ip.id

  for_each = local.public_subnets

  subnet_id = aws_subnet.this[each.key].id

  tags = {
    Name = "Main NAT Gateway"
  }
}