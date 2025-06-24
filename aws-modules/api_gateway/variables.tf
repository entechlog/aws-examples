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

variable "api_key_required" {
  description = "Whether API key is required for requests"
  type        = bool
  default     = false
}

variable "throttle_rate_limit" {
  description = "API Gateway throttle rate limit (requests per second)"
  type        = number
  default     = 10000
}

variable "throttle_burst_limit" {
  description = "API Gateway throttle burst limit"
  type        = number
  default     = 5000
}

variable "quota_limit" {
  description = "API Gateway quota limit"
  type        = number
  default     = 20000
}

variable "quota_period" {
  description = "API Gateway quota period (DAY, WEEK, MONTH)"
  type        = string
  default     = "WEEK"
}