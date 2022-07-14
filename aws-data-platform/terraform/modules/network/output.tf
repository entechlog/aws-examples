output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "private_subnet_id" {
  value = aws_subnet.private.*.id
}

output "public_subnet_id" {
  value = aws_subnet.public.*.id
}

output "security_group" {
  value = aws_security_group.sg.id
}