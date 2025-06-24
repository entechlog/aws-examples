output "api_full_url" {
  description = "The full API Gateway endpoint URL including the resource name"
  value       = "${aws_api_gateway_deployment.api_deployment.invoke_url}/${var.resource_name}"
}

output "rest_api_id" {
  description = "The ID of the REST API"
  value       = aws_api_gateway_rest_api.api.id
}

output "rest_api_execution_arn" {
  description = "The execution ARN of the REST API"
  value       = aws_api_gateway_rest_api.api.execution_arn
}

# API Key outputs (only available if api_key_required is true)
output "api_key_id" {
  description = "The API key ID"
  value       = var.api_key_required ? aws_api_gateway_api_key.api_key[0].id : null
}

output "api_key_value" {
  description = "The API key value"
  value       = var.api_key_required ? aws_api_gateway_api_key.api_key[0].value : null
  sensitive   = true
}

output "usage_plan_id" {
  description = "The usage plan ID"
  value       = var.api_key_required ? aws_api_gateway_usage_plan.usage_plan[0].id : null
}