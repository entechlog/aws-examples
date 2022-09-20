resource "aws_instance" "bastion_host" {
  ami           = "ami-05fa00d4c63e32376"
  instance_type = "t2.micro"
  subnet_id     = var.public_subnet_id

  vpc_security_group_ids = [var.ssh_security_group_id]

  key_name = "ssh-key"

  tags = merge(local.tags, {
    Name        = "${lower(var.env_code)}-${lower(var.project_code)}-bastion-host"
    Environment = "${upper(var.env_code)}"
  })

}

resource "aws_instance" "kafka_client" {
  ami                         = "ami-05fa00d4c63e32376"
  instance_type               = "t2.small"
  subnet_id                   = var.private_subnet_id
  associate_public_ip_address = false
  user_data                   = file("${path.module}/userdata/setup_kafka_client.sh")

  vpc_security_group_ids = [var.ssh_security_group_id]

  key_name = "ssh-key"

  tags = merge(local.tags, {
    Name        = "${lower(var.env_code)}-${lower(var.project_code)}-kafka-client"
    Environment = "${upper(var.env_code)}"
  })

}

resource "aws_key_pair" "ssh_key" {
  key_name   = "ssh-key"
  public_key = var.ssh_public_key
}

output "bastion_host_dns" {
  value = aws_instance.bastion_host.public_dns
}

output "bastion_host_ip" {
  value = aws_instance.bastion_host.public_ip
}

output "kafka_client_dns" {
  value = aws_instance.kafka_client.public_dns
}

output "kafka_client_ip" {
  value = aws_instance.kafka_client.public_ip
}