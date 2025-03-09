resource "aws_secretsmanager_secret" "snowflake_credentials" {
  name                    = "snowflake-credentials"
  description             = "Snowflake credentials for Lambda API"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "snowflake_credentials_version" {
  secret_id = aws_secretsmanager_secret.snowflake_credentials.id
  secret_string = jsonencode({
    user     = var.snowflake_user,
    password = var.snowflake_password,
    account  = var.snowflake_account
  })
}
