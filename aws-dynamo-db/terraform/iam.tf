# -------------------------------------------------------------------------
# IAM Role for Lambda Functions in the Source Account
# -------------------------------------------------------------------------
resource "aws_iam_role" "dynamodb_access_role" {
  provider = aws.app
  name     = "${local.resource_name_prefix}-dynamodb-access-role-${data.aws_caller_identity.data.account_id}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "lambda.amazonaws.com" },
        Action    = "sts:AssumeRole",
      },
      {
        Effect    = "Allow",
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.data.account_id}:root" },
        Action    = "sts:AssumeRole",
      }
    ]
  })
}

# -------------------------------------------------------------------------
# DynamoDB Access Policy Document
# -------------------------------------------------------------------------
data "aws_iam_policy_document" "dynamodb_access_policy" {
  statement {
    effect    = "Allow"
    actions   = ["dynamodb:ExportTableToPointInTime"]
    resources = ["arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.app.account_id}:table/*"]
  }
}

# -------------------------------------------------------------------------
# DynamoDB Access Policy
# -------------------------------------------------------------------------
resource "aws_iam_policy" "dynamodb_access_policy" {
  provider    = aws.app
  name        = "DynamoDBAccessPolicy"
  description = "Policy for accessing DynamoDB tables"
  policy      = data.aws_iam_policy_document.dynamodb_access_policy.json
}

# -------------------------------------------------------------------------
# IAM Role Policy Attachment for DynamoDB Access
# -------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "dynamodb_access_attachment" {
  provider   = aws.app
  role       = aws_iam_role.dynamodb_access_role.name
  policy_arn = aws_iam_policy.dynamodb_access_policy.arn
}

# -------------------------------------------------------------------------
# IAM Role for Lambda Functions in the Target Account
# -------------------------------------------------------------------------
resource "aws_iam_role" "lambda_execution_role" {
  provider = aws.data
  name     = "${local.resource_name_prefix}-lambda-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action    = "sts:AssumeRole",
    }]
  })
}

# -------------------------------------------------------------------------
# IAM Policy Document for S3 Access from Lambda Functions
# -------------------------------------------------------------------------
data "aws_iam_policy_document" "s3_access_source" {
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
    ]
  }
}

# -------------------------------------------------------------------------
# IAM Policy Document for S3 Access from Lambda Functions
# -------------------------------------------------------------------------
data "aws_iam_policy_document" "s3_access_target" {
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
      "arn:aws:s3:::${local.target_bucket_name}",
      "arn:aws:s3:::${local.target_bucket_name}/*"
    ]
  }
}

# -------------------------------------------------------------------------
# IAM Policy Document for CloudWatch Logs Access
# -------------------------------------------------------------------------
data "aws_iam_policy_document" "lambda_logging" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.data.account_id}:*"]
  }
}

# -------------------------------------------------------------------------
# Attach Inline Policies for S3 Access and Logging to Lambda Execution Role
# -------------------------------------------------------------------------
resource "aws_iam_role_policy" "inline_s3_policy_for_lambda" {
  provider = aws.data
  role     = aws_iam_role.lambda_execution_role.id
  name     = "${local.resource_name_prefix}-lambda-s3-inline-policy"
  policy   = data.aws_iam_policy_document.s3_access_target.json
}

resource "aws_iam_role_policy" "inline_s3_policy_for_dynamodb" {
  provider = aws.app
  role     = aws_iam_role.dynamodb_access_role.id
  name     = "${local.resource_name_prefix}-lambda-s3-inline-policy"
  policy   = data.aws_iam_policy_document.s3_access_source.json
}

resource "aws_iam_role_policy" "inline_logging_policy_for_lambda" {
  provider = aws.data
  role     = aws_iam_role.lambda_execution_role.id
  name     = "${local.resource_name_prefix}-lambda-logging-inline-policy"
  policy   = data.aws_iam_policy_document.lambda_logging.json
}

# -------------------------------------------------------------------------
# Policy to Allow Lambda Functions to Assume the DynamoDB Access Role
# -------------------------------------------------------------------------
resource "aws_iam_policy" "assume_dynamodb_role_policy" {
  provider    = aws.data
  name        = "${local.resource_name_prefix}-assume-dynamodb-export-role"
  description = "Policy to allow assuming the DynamoDB access role"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "sts:AssumeRole",
        Resource = aws_iam_role.dynamodb_access_role.arn
      },
    ],
  })
}

# -------------------------------------------------------------------------
# Attach Policy to Lambda Execution Role for Assuming DynamoDB Access Role
# -------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "assume_dynamodb_role_attachment" {
  provider   = aws.data
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.assume_dynamodb_role_policy.arn
}
