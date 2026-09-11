locals {
  selected_azs = slice(data.aws_availability_zones.available.names, 0, 2)
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
  vpc_id = aws_vpc.this.id
  for_each = var.subnet_config
  availability_zone = each.value.az
  cidr_block = each.value.cidr_block

  tags = {
    Name = each.key
    Access = each.value.public ? "Public" : "Private"
  }
}