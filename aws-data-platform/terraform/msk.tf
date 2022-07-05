module "msk" {
  source = "./modules/msk"

  env_code          = var.env_code
  project_code      = var.project_code
  private_subnet_id = module.vpc.private_subnet_id
  security_group_id = module.vpc.security_group

  mongodbdb_uri                    = var.mongodbdb_uri
  mongodb_username                 = var.mongodb_username
  mongodbdb_password               = var.mongodbdb_password
  mongodb_vpce_service_name        = var.mongodb_vpce_service_name
  snowflake_url_name               = var.snowflake_url_name
  snowflake_user_name              = var.snowflake_user_name
  snowflake_private_key            = var.snowflake_private_key
  snowflake_private_key_passphrase = var.snowflake_private_key_passphrase

  depends_on = [module.vpc]
}