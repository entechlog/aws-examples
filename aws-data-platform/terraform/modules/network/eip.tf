/* Elastic IP for NAT */
resource "aws_eip" "nat_eip" {
  count = length(var.public_subnet_cidr_block)
  vpc   = true

  tags = merge(local.tags, {
    Name = format("${lower(var.env_code)}-${lower(var.project_code)}-eip-%02d", count.index + 1)
  })

  depends_on = [aws_internet_gateway.ig]
}