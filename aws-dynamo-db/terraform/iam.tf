# -------------------------------------------------------------------------
# IAM Role for Lambda Functions
# -------------------------------------------------------------------------
# This role is assumed by Lambda functions for both DynamoDB export and S3 operations.
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
# IAM Policy for DynamoDB Access
# -------------------------------------------------------------------------
# This policy allows Lambda functions to export data from DynamoDB.
data "aws_iam_policy_document" "dynamodb_access" {
  statement {
    effect    = "Allow"
    actions   = ["dynamodb:ExportTableToPointInTime"]
    resources = ["arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/*"]
  }
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
      "arn:aws:s3:::${local.destination_bucket_name}",
      "arn:aws:s3:::${local.destination_bucket_name}/*"
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
# Attach the DynamoDB access, S3 access, and logging policies as inline policies to the Lambda execution role.
resource "aws_iam_role_policy" "inline_policy_for_lambda" {
  role   = aws_iam_role.lambda_execution_role.id
  name   = "${local.resource_name_prefix}-lambda-inline-policy"
  policy = data.aws_iam_policy_document.dynamodb_access.json
}

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
