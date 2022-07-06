module "mwaa" {
  source = "./modules/mwaa"

  env_code          = var.env_code
  project_code      = var.project_code
  private_subnet_id = module.vpc.private_subnet_id
  security_group_id = module.vpc.security_group

  depends_on = [module.vpc]
}