output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "private_subnet_id" {
  value = aws_subnet.private.*.id
}

output "public_subnet_id" {
  value = aws_subnet.public.*.id
}

output "kafka_security_group_id" {
  value = aws_security_group.kafka_sg.id
}

output "ssh_security_group_id" {
  value = aws_security_group.ssh_sg.id
}