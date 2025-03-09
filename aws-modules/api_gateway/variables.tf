variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "stage_name" {
  description = "Deployment stage for API Gateway"
  type        = string
}

variable "lambda_function_arn" {
  description = "ARN of the Lambda function to integrate"
  type        = string
}

variable "lambda_invoke_arn" {
  description = "Invoke ARN of the Lambda function to integrate"
  type        = string
}

variable "resource_name" {
  description = "API resource name (typically same as the Lambda function name)"
  type        = string
}
