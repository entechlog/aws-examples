resource "aws_secretsmanager_secret" "env_code" {
  name = "airflow/variables/env_code"
}

resource "aws_secretsmanager_secret_version" "env_code" {
  secret_id     = aws_secretsmanager_secret.env_code.id
  secret_string = lower(var.env_code)
}

resource "aws_secretsmanager_secret" "snowflake_conn" {
  name = "airflow/connections/snowflake_conn"
}

resource "aws_secretsmanager_secret_version" "snowflake_conn" {
  secret_id = aws_secretsmanager_secret.snowflake_conn.id
  secret_string = jsonencode({ conn_id = lookup(var.snowflake_auth_configs, "conn_id"),
    conn_type = lookup(var.snowflake_auth_configs, "conn_type"),
    host      = lookup(var.snowflake_auth_configs, "host"),
    login     = lookup(var.snowflake_auth_configs, "login"),
    password  = lookup(var.snowflake_auth_configs, "password"),
    extra     = lookup(var.snowflake_auth_configs, "extra")
  })
}