# Create the secret in AWS Secrets Manager
resource "aws_secretsmanager_secret" "db_password" {
  name = "rds/${local.resource_name_prefix}-demo-db/password"
}

resource "aws_secretsmanager_secret_version" "db_password_version" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = var.db_password

  depends_on = [aws_secretsmanager_secret.db_password]
}