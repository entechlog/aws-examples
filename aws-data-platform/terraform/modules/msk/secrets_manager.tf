resource "aws_secretsmanager_secret" "msk" {
  name       = "AmazonMSK_${lower(var.env_code)}_${lower(var.project_code)}_kafka_user"
  kms_key_id = aws_kms_key.kms.key_id
}

resource "aws_secretsmanager_secret_version" "msk_auth" {
  secret_id     = aws_secretsmanager_secret.msk.id
  secret_string = jsonencode({ username = lookup(var.kafka_sasl_scram_auth_configs, "username"), password = lookup(var.kafka_sasl_scram_auth_configs, "password") })
}

resource "aws_secretsmanager_secret_policy" "msk" {
  secret_arn = aws_secretsmanager_secret.msk.arn
  policy     = <<POLICY
{
  "Version" : "2012-10-17",
  "Statement" : [ {
    "Sid": "AWSKafkaResourcePolicy",
    "Effect" : "Allow",
    "Principal" : {
      "Service" : "kafka.amazonaws.com"
    },
    "Action" : "secretsmanager:getSecretValue",
    "Resource" : "${aws_secretsmanager_secret.msk.arn}"
  } ]
}
POLICY
}

resource "aws_msk_scram_secret_association" "sasl_scram" {
  count           = var.kafka_sasl_scram_auth_enabled ? 1 : 0
  cluster_arn     = aws_msk_cluster.main.arn
  secret_arn_list = [aws_secretsmanager_secret.msk.arn]

  depends_on = [
    aws_secretsmanager_secret_version.msk_auth
  ]
}

// Snowflake connector credentials

resource "aws_secretsmanager_secret" "snowflake" {
  name       = "${lower(var.env_code)}_${lower(var.project_code)}_snowflake"
  kms_key_id = aws_kms_key.kms.key_id
}

resource "aws_secretsmanager_secret_version" "snowflake_auth" {
  secret_id     = aws_secretsmanager_secret.snowflake.id
  secret_string = jsonencode({ private_key = var.snowflake_private_key, private_key_passphrase = var.snowflake_private_key_passphrase })
}

resource "aws_secretsmanager_secret_policy" "snowflake" {
  secret_arn = aws_secretsmanager_secret.snowflake.arn
  policy     = <<POLICY
{
  "Version" : "2012-10-17",
  "Statement" : [ {
    "Sid": "AWSKafkaResourcePolicy",
    "Effect" : "Allow",
    "Principal" : {
      "Service" : "kafka.amazonaws.com"
    },
    "Action" : "secretsmanager:getSecretValue",
    "Resource" : "${aws_secretsmanager_secret.snowflake.arn}"
  } ]
}
POLICY
}
