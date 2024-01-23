output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_id" {
  value = module.vpc.private_subnet_id
}

output "public_subnet_id" {
  value = module.vpc.public_subnet_id
}

output "ssh_security_group_id" {
  value = module.vpc.ssh_security_group_id
}