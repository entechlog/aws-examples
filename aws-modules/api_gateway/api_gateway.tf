resource "aws_api_gateway_rest_api" "api" {
  name        = var.api_name
  description = "API Gateway for Lambda integration"
}

resource "aws_api_gateway_resource" "function_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = lower(var.resource_name)
}

resource "aws_api_gateway_method" "any_method" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource.function_resource.id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = var.api_key_required
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.function_resource.id
  http_method             = aws_api_gateway_method.any_method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = var.lambda_invoke_arn
}

resource "aws_lambda_permission" "apigw_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on  = [aws_api_gateway_integration.lambda_integration]
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = var.stage_name
}

# API Key Resources (only created if api_key_required is true)
resource "aws_api_gateway_api_key" "api_key" {
  count       = var.api_key_required ? 1 : 0
  name        = "${var.api_name}-api-key"
  description = "API key for ${var.api_name}"
}

resource "aws_api_gateway_usage_plan" "usage_plan" {
  count       = var.api_key_required ? 1 : 0
  name        = "${var.api_name}-usage-plan"
  description = "Usage plan for ${var.api_name}"

  api_stages {
    api_id = aws_api_gateway_rest_api.api.id
    stage  = var.stage_name
  }

  throttle_settings {
    rate_limit  = var.throttle_rate_limit
    burst_limit = var.throttle_burst_limit
  }

  quota_settings {
    limit  = var.quota_limit
    period = var.quota_period
  }
  
  # Add this to ensure deployment completes before creating usage plan
  depends_on = [aws_api_gateway_deployment.api_deployment]
}

resource "aws_api_gateway_usage_plan_key" "usage_plan_key" {
  count         = var.api_key_required ? 1 : 0
  key_id        = aws_api_gateway_api_key.api_key[0].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.usage_plan[0].id
}