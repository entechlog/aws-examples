# -------------------------------------------------------------------------
# IAM Role for Lambda Functions in the Target Account
# -------------------------------------------------------------------------
resource "aws_iam_role" "lambda_execution_role" {
  name = "${local.resource_name_prefix}-lambda-execution-role"
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
    resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
  }
}

# -------------------------------------------------------------------------
# Attach Inline Policies for S3 Access and Logging to Lambda Execution Role
# -------------------------------------------------------------------------
resource "aws_iam_role_policy" "inline_s3_policy_for_lambda" {
  role   = aws_iam_role.lambda_execution_role.id
  name   = "${local.resource_name_prefix}-lambda-s3-inline-policy"
  policy = data.aws_iam_policy_document.s3_access_target.json
}

resource "aws_iam_role_policy" "inline_logging_policy_for_lambda" {
  role   = aws_iam_role.lambda_execution_role.id
  name   = "${local.resource_name_prefix}-lambda-logging-inline-policy"
  policy = data.aws_iam_policy_document.lambda_logging.json
}
