output "snowflake_api_endpoint" {
  description = "The URL of the API Gateway endpoint for the Snowflake Lambda"
  value       = module.api_gateway.api_full_url
}

output "lambda_function_arn" {
  description = "ARN of the Snowflake Lambda function"
  value       = module.lambda_function.lambda_function_arn
}

output "snowflake_secret_arn" {
  description = "ARN of the Snowflake credentials secret in Secrets Manager"
  value       = aws_secretsmanager_secret.snowflake_credentials.arn
}
