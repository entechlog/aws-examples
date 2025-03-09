resource "aws_iam_role" "snowflake_api_lambda_role" {
  name = "snowflake-api-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "snowflake_api_lambda_secrets_policy" {
  name = "snowflake-api-lambda-secrets-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      Resource = aws_secretsmanager_secret.snowflake_credentials.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "snowflake_api_lambda_basic" {
  role       = aws_iam_role.snowflake_api_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "snowflake_api_lambda_secrets" {
  role       = aws_iam_role.snowflake_api_lambda_role.name
  policy_arn = aws_iam_policy.snowflake_api_lambda_secrets_policy.arn
}
