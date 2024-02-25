/* Private subnet */
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.private_subnet_cidr_block)
  cidr_block              = var.private_subnet_cidr_block[count.index]
  availability_zone       = var.availability_zone[count.index]
  map_public_ip_on_launch = false

  tags = merge(local.tags, {
    Name = format("${local.resource_name_prefix}-private-%02d", count.index + 1)
  })
}

/* If you are not using private link, then to access services outside VPC MSK connect needs internet access */
/* See https://docs.aws.amazon.com/msk/latest/developerguide/msk-connect-internet-access.html */

/* Public subnet */
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.public_subnet_cidr_block)
  cidr_block              = var.public_subnet_cidr_block[count.index]
  availability_zone       = var.availability_zone[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.tags, {
    Name = format("${local.resource_name_prefix}-public-%02d", count.index + 1)
  })
}