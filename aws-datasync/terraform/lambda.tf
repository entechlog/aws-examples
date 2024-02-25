# -------------------------------------------------------------------------
# Destination S3 bucket for storing copied data
# -------------------------------------------------------------------------
module "destination_s3_bucket" {
  source         = "../../aws-modules/s3"
  s3_bucket_name = ["demo-destination-lambda"]
  use_env_code   = true
  providers      = { aws = aws.prd }
}

# -------------------------------------------------------------------------
# S3 bucket policy for destination bucket, allowing Lambda copy function access
# -------------------------------------------------------------------------
resource "aws_s3_bucket_policy" "destination_lambda_bucket_policy" {
  provider = aws.prd
  bucket   = local.lambda_destination_bucket_name
  policy = jsonencode({
    Version = "2008-10-17",
    Statement = [
      {
        Sid       = "LambdaS3CopyAccess",
        Effect    = "Allow",
        Principal = { AWS = aws_iam_role.lambda_execution_role.arn },
        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:AbortMultipartUpload",
          "s3:DeleteObject",
          "s3:GetObject",
          "s3:ListMultipartUploadParts",
          "s3:PutObject",
          "s3:GetObjectTagging",
          "s3:PutObjectTagging"
        ],
        Resource = [
          "arn:aws:s3:::${local.lambda_destination_bucket_name}",
          "arn:aws:s3:::${local.lambda_destination_bucket_name}/*"
        ]
      }
    ]
  })
}

# -------------------------------------------------------------------------
# IAM Role for Lambda Functions
# -------------------------------------------------------------------------
# This role is assumed by Lambda functions for S3 operations
resource "aws_iam_role" "lambda_execution_role" {
  name = "${local.resource_name_prefix}-lambda-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Action    = "sts:AssumeRole",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# -------------------------------------------------------------------------
# IAM Policy for S3 Access
# -------------------------------------------------------------------------
# This policy grants Lambda functions permissions for necessary S3 operations.
data "aws_iam_policy_document" "s3_access" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      "arn:aws:s3:::${local.source_bucket_name}",
      "arn:aws:s3:::${local.source_bucket_name}/*",
      "arn:aws:s3:::${local.lambda_destination_bucket_name}",
      "arn:aws:s3:::${local.lambda_destination_bucket_name}/*"
    ]
  }
}

# -------------------------------------------------------------------------
# IAM Policy for Logging
# -------------------------------------------------------------------------
# This policy allows Lambda functions to write logs.
data "aws_iam_policy_document" "lambda_logging" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
  }
}

# -------------------------------------------------------------------------
# Inline Policy Attachment for Lambda Execution Role
# -------------------------------------------------------------------------
# Attach the S3 access, and logging policies as inline policies to the Lambda execution role.

resource "aws_iam_role_policy" "inline_s3_policy_for_lambda" {
  role   = aws_iam_role.lambda_execution_role.id
  name   = "${local.resource_name_prefix}-lambda-s3-inline-policy"
  policy = data.aws_iam_policy_document.s3_access.json
}

resource "aws_iam_role_policy" "inline_logging_policy_for_lambda" {
  role   = aws_iam_role.lambda_execution_role.id
  name   = "${local.resource_name_prefix}-lambda-logging-inline-policy"
  policy = data.aws_iam_policy_document.lambda_logging.json
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
      DESTINATION_BUCKET = local.lambda_destination_bucket_name,
      OUTPUT_PATH        = local.output_path
    }
  }
}

# -------------------------------------------------------------------------
# S3 bucket notification for triggering S3 copy Lambda function
# -------------------------------------------------------------------------
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = local.source_bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_copy_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".json" # Adjust based on your input filter approximation
  }
}

# -------------------------------------------------------------------------
# Lambda permission to allow execution from S3 bucket
# -------------------------------------------------------------------------
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "${local.resource_name_prefix}-AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_copy_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${local.source_bucket_name}"
}
