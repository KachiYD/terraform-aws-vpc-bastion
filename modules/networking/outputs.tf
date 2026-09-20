output "vpc_id" {
  value = aws_vpc.this.id
}

output "vpc_cidr_block" {
  value = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  value = [for key, _ in local.public_subnets : aws_subnet.this[key].id]
}

output "private_subnet_ids" {
  value = [for key, _ in local.private_subnets : aws_subnet.this[key].id]
}