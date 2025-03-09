module "lambda_function" {
  source               = "../aws-modules/lambda"
  function_name        = "get_current_timestamp"
  role_name            = aws_iam_role.snowflake_api_lambda_role.arn
  lambda_runtime       = "python3.9"
  snowflake_secret_arn = aws_secretsmanager_secret.snowflake_credentials.arn
  aws_region           = lower(var.aws_region)
  source_dir           = "./uploads/lambda" # External Lambda source directory
}

module "api_gateway" {
  source              = "../aws-modules/api_gateway"
  api_name            = "snowflake"
  stage_name          = lower(var.env_code)
  resource_name       = "get_current_timestamp"
  lambda_function_arn = module.lambda_function.lambda_function_arn
  lambda_invoke_arn   = module.lambda_function.lambda_invoke_arn
}
