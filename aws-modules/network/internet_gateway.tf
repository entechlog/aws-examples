resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(local.tags, {
    Name = "${local.resource_name_prefix}-ig"
  })
}