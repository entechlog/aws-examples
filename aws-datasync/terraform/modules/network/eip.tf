/* Elastic IP for NAT */
resource "aws_eip" "nat_eip" {
  count  = length(var.public_subnet_cidr_block)
  domain = "vpc"

  tags = merge(local.tags, {
    Name = format("${local.resource_name_prefix}-eip-%02d", count.index + 1)
  })

  depends_on = [aws_internet_gateway.ig]
}