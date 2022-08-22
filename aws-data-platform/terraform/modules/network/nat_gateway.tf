/* NAT */
resource "aws_nat_gateway" "nat_gateway" {
  count         = length(var.public_subnet_cidr_block)
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(local.tags, {
    Name        = format("${lower(var.env_code)}-${lower(var.project_code)}-ngw-%02d", count.index + 1)
    Environment = "${upper(var.env_code)}"
  })

  depends_on = [aws_internet_gateway.ig]
}