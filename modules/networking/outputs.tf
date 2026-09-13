output "public_subnet_id" {
  value = aws_subnet.this["public_sub_1"].id
}