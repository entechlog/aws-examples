# -------------------------------------------------------------------------
# Archive file data block for DynamoDB to S3 export Lambda function package
# -------------------------------------------------------------------------
data "archive_file" "dynamodb_to_s3_export_lambda_package" {
  type        = "zip"
  source_file = "${path.module}/uploads/lambda/dynamo2s3/index.js"
  output_path = "${path.module}/uploads/lambda/dynamo2s3/dynamodb_to_s3_export_lambda.zip"
}

# -------------------------------------------------------------------------
# Resource block for DynamoDB to S3 export Lambda function
# -------------------------------------------------------------------------
resource "aws_lambda_function" "dynamodb_to_s3_export_lambda" {
  provider         = aws.data
  function_name    = "${local.resource_name_prefix}-dynamodb-to-s3-export"
  filename         = data.archive_file.dynamodb_to_s3_export_lambda_package.output_path
  source_code_hash = data.archive_file.dynamodb_to_s3_export_lambda_package.output_base64sha256

  role        = aws_iam_role.lambda_execution_role.arn
  handler     = "index.handler"
  runtime     = "nodejs16.x"
  timeout     = 360
  memory_size = 2048

  environment {
    variables = {
      BUCKET_NAME = local.source_bucket_name
      TABLE_ARNS  = jsonencode([aws_dynamodb_table.game_scores.arn])
      ROLE_ARN    = aws_iam_role.dynamodb_access_role.arn
    }
  }

  tracing_config {
    mode = "Active"
  }
}

# -------------------------------------------------------------------------
# Archive file data block for S3 to S3 copy Lambda function package
# -------------------------------------------------------------------------
data "archive_file" "s3_copy_lambda_package" {
  type        = "zip"
  source_file = "${path.module}/uploads/lambda/s32s3/index.js"
  output_path = "${path.module}/uploads/lambda/s32s3/s3_copy_lambda.zip"
}

# -------------------------------------------------------------------------
# Resource block for S3 to S3 copy Lambda function
# -------------------------------------------------------------------------
resource "aws_lambda_function" "s3_copy_lambda" {
  provider         = aws.data
  function_name    = "${local.resource_name_prefix}-s3-copy"
  filename         = data.archive_file.s3_copy_lambda_package.output_path
  source_code_hash = data.archive_file.s3_copy_lambda_package.output_base64sha256

  role        = aws_iam_role.lambda_execution_role.arn
  handler     = "index.handler"
  runtime     = "nodejs16.x"
  timeout     = 360
  memory_size = 2048

  environment {
    variables = {
      SOURCE_BUCKET      = local.source_bucket_name,
      DESTINATION_BUCKET = local.target_bucket_name,
      OUTPUT_PATH        = local.output_path,
      TABLE_ARNS         = jsonencode([aws_dynamodb_table.game_scores.arn])
    }
  }
}

# -------------------------------------------------------------------------
# Lambda permission to allow execution from S3 bucket
# -------------------------------------------------------------------------
resource "aws_lambda_permission" "allow_bucket" {
  provider = aws.data

  statement_id  = "${local.resource_name_prefix}-allow-execution-from-s3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_copy_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = module.source_s3_bucket.aws_s3_bucket__arn[0]
}
