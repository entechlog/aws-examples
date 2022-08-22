resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(local.tags, {
    Name        = "${lower(var.env_code)}-${lower(var.project_code)}-ig"
    Environment = "${upper(var.env_code)}"
  })
}