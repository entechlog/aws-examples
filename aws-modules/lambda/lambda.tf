resource "aws_lambda_function" "lambda_function" {
  function_name = var.function_name
  role          = var.role_name
  handler       = "${lower(var.function_name)}.lambda_handler"
  runtime       = var.lambda_runtime
  timeout       = 15

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = merge(
      var.environment_variables
    )
  }
}