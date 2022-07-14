module "vpc" {
  source = "./modules/network"

  env_code                  = var.env_code
  project_code              = var.project_code
  aws_region                = var.aws_region
  availability_zone         = var.availability_zone
  vpc_cidr_block            = var.vpc_cidr_block
  private_subnet_cidr_block = var.private_subnet_cidr_block
  public_subnet_cidr_block  = var.public_subnet_cidr_block
  open_monitoring           = var.open_monitoring
}