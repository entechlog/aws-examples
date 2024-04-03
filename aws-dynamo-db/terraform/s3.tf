# -------------------------------------------------------------------------
# S3 bucket for source data in the source account
# -------------------------------------------------------------------------
module "source_s3_bucket" {
  source         = "../../aws-modules/s3"
  s3_bucket_name = ["dynamodb-export"]
  use_env_code   = true
  providers      = { aws = aws.app }
}

# -------------------------------------------------------------------------
# S3 bucket for destination data in the target account
# -------------------------------------------------------------------------
module "destination_s3_bucket" {
  source         = "../../aws-modules/s3"
  s3_bucket_name = ["landing-zone"]
  use_env_code   = true
  providers      = { aws = aws.data }
}

# -------------------------------------------------------------------------
# S3 bucket notification to trigger S3 copy Lambda function
# This notification is set on the source bucket to trigger a Lambda function
# for copying data to the destination bucket upon new object creation.
# -------------------------------------------------------------------------
resource "aws_s3_bucket_notification" "bucket_notification" {
  provider = aws.app

  bucket = module.source_s3_bucket.aws_s3_bucket__name[0]

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_copy_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = "manifest-files.json" # Adjust based on your input file types
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

# -------------------------------------------------------------------------
# S3 bucket policy for the destination bucket
# This policy allows the Lambda function to access the destination bucket
# for operations like put, get, list, and delete objects.
# -------------------------------------------------------------------------
resource "aws_s3_bucket_policy" "lambda_bucket_policy_destination" {
  provider = aws.data
  bucket   = local.target_bucket_name
  policy = jsonencode({
    Version = "2008-10-17",
    Statement = [
      {
        Sid       = "LambdaS3WriteAccess",
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
          "arn:aws:s3:::${local.target_bucket_name}",
          "arn:aws:s3:::${local.target_bucket_name}/*"
        ]
      }
    ]
  })
}

# -------------------------------------------------------------------------
# S3 bucket policy for the source bucket
# This policy grants the Lambda function permissions to access the source bucket
# for reading objects when triggered by the S3 bucket notification.
# -------------------------------------------------------------------------
resource "aws_s3_bucket_policy" "source_bucket_policy_lambda" {
  provider = aws.app
  bucket   = local.source_bucket_name
  policy = jsonencode({
    Version = "2008-10-17",
    Statement = [
      {
        Sid       = "LambdaS3ReadAccess",
        Effect    = "Allow",
        Principal = { AWS = aws_iam_role.lambda_execution_role.arn },
        Action = [
          "s3:Get*",
          "s3:List*"
        ],
        Resource = [
          "arn:aws:s3:::${local.source_bucket_name}",
          "arn:aws:s3:::${local.source_bucket_name}/*"
        ]
      }
    ]
  })
}
