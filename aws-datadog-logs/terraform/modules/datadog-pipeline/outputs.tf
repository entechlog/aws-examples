# API Gateway outputs
output "api_gateway_url" {
  description = "API Gateway endpoint URL for Datadog logs"
  value       = module.datadog_api_gateway.api_full_url
}

output "api_key_value" {
  description = "API Gateway API key for authentication"
  value       = module.datadog_api_gateway.api_key_value
  sensitive   = true
}

output "api_key_id" {
  description = "API Gateway API key ID"
  value       = module.datadog_api_gateway.api_key_id
}

# Firehose outputs
output "firehose_delivery_stream_name" {
  description = "Firehose delivery stream name"
  value       = module.datadog_firehose.delivery_stream_name
}

output "firehose_delivery_stream_arn" {
  description = "Firehose delivery stream ARN"
  value       = module.datadog_firehose.delivery_stream_arn
}

# Lambda outputs
output "lambda_function_arn" {
  description = "Lambda function ARN"
  value       = aws_lambda_function.datadog_lambda.arn
}

# Event-specific outputs
output "event_name" {
  description = "Event name (normalized with hyphens)"
  value       = local.normalized_event_name
}

output "destination_type" {
  description = "Destination type"
  value       = var.destination_type
}

output "table_name" {
  description = "Target table name (for Snowflake)"
  value       = local.table_name
}