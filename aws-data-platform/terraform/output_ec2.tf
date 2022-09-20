output "bastion_host_dns" {
  value       = module.ec2.bastion_host_dns
  description = "DNS record for bastion host EC2 instance"
}

output "bastion_host_ip" {
  value       = module.ec2.bastion_host_ip
  description = "IP record for bastion host EC2 instance"
}

output "kafka_client_dns" {
  value       = module.ec2.kafka_client_dns
  description = "DNS record for kafka client EC2 instance"
}

output "kafka_client_ip" {
  value       = module.ec2.kafka_client_ip
  description = "IP record for kafka client EC2 instance"
}
