# Declare the data source
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_region" "current" {}

data "aws_caller_identity" "app" {
  provider = aws.app
}

data "aws_caller_identity" "data" {
  provider = aws.data
}