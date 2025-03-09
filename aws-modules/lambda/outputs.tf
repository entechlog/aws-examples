output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.lambda_function.arn
}

output "lambda_invoke_arn" {
  description = "The Lambda function's invoke ARN"
  value       = aws_lambda_function.lambda_function.invoke_arn
}
