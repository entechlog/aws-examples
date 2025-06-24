# Dynamic outputs for all pipelines
locals {
  # Define all your pipeline modules here
  all_pipelines = {
    "system_events_s3"        = module.user_events_s3_pipeline
    "system_events_snowflake" = module.system_events_snowflake_pipeline
  }
}

# Dynamic API Gateway URLs
output "api_gateway_urls" {
  description = "API Gateway endpoint URLs for all Datadog pipelines"
  value = {
    for name, pipeline in local.all_pipelines : name => pipeline.api_gateway_url
  }
}

# Dynamic API Keys
output "api_key_values" {
  description = "API Gateway API keys for all pipelines"
  sensitive   = true
  value = {
    for name, pipeline in local.all_pipelines : name => pipeline.api_key_value
  }
}

# Dynamic API Key IDs
output "api_key_ids" {
  description = "API Gateway API key IDs for all pipelines"
  value = {
    for name, pipeline in local.all_pipelines : name => pipeline.api_key_id
  }
}

# Dynamic Firehose Stream Names
output "firehose_stream_names" {
  description = "Firehose delivery stream names for all pipelines"
  value = {
    for name, pipeline in local.all_pipelines : name => pipeline.firehose_delivery_stream_name
  }
}

# Dynamic Lambda Function ARNs
output "lambda_function_arns" {
  description = "Lambda function ARNs for all pipelines"
  value = {
    for name, pipeline in local.all_pipelines : name => pipeline.lambda_function_arn
  }
}