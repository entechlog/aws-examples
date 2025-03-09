/* Routing table for public subnet */
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(local.tags, {
    Name = "${local.resource_name_prefix}-public-route-table"
  })
}

/* Routing table for private subnets */
resource "aws_route_table" "private" {
  count  = length(var.private_subnet_cidr_block)
  vpc_id = aws_vpc.vpc.id

  tags = merge(local.tags, {
    Name = format("${local.resource_name_prefix}-private-route-table-%02d", count.index + 1)
  })
}

/* Routes for public subnets */
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

/* Routes for private subnets via NAT Gateway */
resource "aws_route" "private_nat_gateway" {
  count = var.create_single_nat_gateway ? length(aws_subnet.private.*.id) : length(aws_subnet.public.*.id) * length(aws_subnet.private.*.id)

  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.create_single_nat_gateway ? aws_nat_gateway.this[0].id : element(aws_nat_gateway.this.*.id, count.index % length(aws_subnet.public.*.id))
}

/* Route table associations for public subnets */
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidr_block)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

/* Route table associations for private subnets */
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidr_block)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
