resource "aws_instance" "bastion_host" {
  ami           = "ami-05fa00d4c63e32376"
  instance_type = "t2.micro"
  subnet_id     = var.public_subnet_id

  vpc_security_group_ids = [var.ssh_security_group_id]

  key_name = "ssh-key"

  tags = merge(local.tags, {
    Name = "${local.resource_name_prefix}-bastion-host"
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