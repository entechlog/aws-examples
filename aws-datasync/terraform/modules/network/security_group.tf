resource "aws_security_group" "ssh_sg" {
  name        = "${local.resource_name_prefix}-ssh-sg"
  description = "Security group for ${var.project_code} SSH in ${upper(var.env_code)}"
  vpc_id      = aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.remote_cidr_block, var.vpc_cidr_block]
  }
  tags = merge(local.tags, {
    Name = "${local.resource_name_prefix}-ssh-sg"
  })
}