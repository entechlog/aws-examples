/* Routing table for public subnet */
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(local.tags, {
    Name        = "${lower(var.env_code)}-${lower(var.project_code)}-public-route-table"
    Environment = "${upper(var.env_code)}"
  })
}

/* Routing table for private subnet */
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(local.tags, {
    Name        = "${lower(var.env_code)}-${lower(var.project_code)}-private-route-table"
    Environment = "${upper(var.env_code)}"
  })

}

/* Routes */
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

resource "aws_route" "private_nat_gateway" {
  count                  = length(aws_nat_gateway.nat_gateway)
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway[count.index].id
}

/* Route table associations */
resource "aws_main_route_table_association" "private" {
  vpc_id         = aws_vpc.vpc.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidr_block)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidr_block)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}