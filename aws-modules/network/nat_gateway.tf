resource "aws_nat_gateway" "this" {
  count = var.create_single_nat_gateway ? 1 : length(aws_subnet.public.*.id)

  allocation_id = element(aws_eip.nat_eip.*.id, count.index)
  subnet_id     = var.create_single_nat_gateway ? element(aws_subnet.public.*.id, 0) : element(aws_subnet.public.*.id, count.index)
  tags          = merge(local.tags, { Name = "${local.resource_name_prefix}-nat-gateway-${count.index}" })

  depends_on = [aws_internet_gateway.ig]
}
