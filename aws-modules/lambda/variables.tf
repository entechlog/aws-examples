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

variable "snowflake_secret_arn" {
  description = "ARN of the Secrets Manager secret for Snowflake credentials"
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
