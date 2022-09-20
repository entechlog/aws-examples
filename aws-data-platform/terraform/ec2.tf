module "ec2" {
  source = "./modules/ec2"

  env_code              = var.env_code
  project_code          = var.project_code
  private_subnet_id     = module.vpc.private_subnet_id[0]
  public_subnet_id      = module.vpc.public_subnet_id[0]
  ssh_security_group_id = module.vpc.ssh_security_group_id
  ssh_public_key        = var.ssh_public_key

  depends_on = [module.vpc]
}
