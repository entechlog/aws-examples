output "api_full_url" {
  description = "The full API Gateway endpoint URL including the resource name"
  value       = "${aws_api_gateway_deployment.api_deployment.invoke_url}/${var.resource_name}"
}
