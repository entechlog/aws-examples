# Declare the data source
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

data "aws_caller_identity" "dev" {}

data "aws_caller_identity" "prd" {

  provider = aws.prd

}