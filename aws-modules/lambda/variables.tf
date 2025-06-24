variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "role_name" {
  description = "Name of the IAM role for the Lambda"
  type        = string
}

variable "lambda_runtime" {
  description = "Lambda runtime"
  type        = string
}

variable "aws_region" {
  description = "AWS region for Lambda"
  type        = string
  default     = "us-west-2"
}

variable "source_dir" {
  description = "Directory containing the Lambda source code"
  type        = string
}

# Add environment variables support
variable "environment_variables" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}