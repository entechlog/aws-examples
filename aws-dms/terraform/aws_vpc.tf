module "data_vpc" {
  source                    = "../../aws-modules/network"
  env_code                  = var.env_code
  project_code              = "${var.project_code}-data"
  aws_region                = var.aws_region
  availability_zone         = data.aws_availability_zones.available.names
  vpc_cidr_block            = var.vpc_cidr_block
  private_subnet_cidr_block = var.private_subnet_cidr_block
  public_subnet_cidr_block  = var.public_subnet_cidr_block
  remote_cidr_block         = var.remote_cidr_block
  use_env_code              = false
  create_single_nat_gateway = true
}