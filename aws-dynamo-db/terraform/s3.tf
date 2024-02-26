# Source Account: Create an S3 bucket
module "source_s3_bucket" {
  source         = "../../aws-modules/s3"
  s3_bucket_name = ["landing-zone"]
  use_env_code   = true
}

# -------------------------------------------------------------------------
# Destination S3 bucket for storing copied data
# -------------------------------------------------------------------------
module "destination_s3_bucket" {
  source         = "../../aws-modules/s3"
  s3_bucket_name = ["raw-zone"]
  use_env_code   = true
  providers      = { aws = aws.prd }
}

# -------------------------------------------------------------------------
# S3 bucket policy for destination bucket, allowing Lambda copy function access
# -------------------------------------------------------------------------
resource "aws_s3_bucket_policy" "destination_lambda_bucket_policy" {
  provider = aws.prd
  bucket   = local.destination_bucket_name
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
          "arn:aws:s3:::${local.destination_bucket_name}",
          "arn:aws:s3:::${local.destination_bucket_name}/*"
        ]
      },
      {
        Sid       = "SnowflakeReadOnlyAccess",
        Effect    = "Allow",
        Principal = { AWS = aws_iam_role.snowflake_s3_access_role.arn },
        Action = [
          "s3:GetObject*",
          "s3:GetBucket*",
          "s3:List*"
        ],
        Resource = [
          "arn:aws:s3:::${local.destination_bucket_name}",
          "arn:aws:s3:::${local.destination_bucket_name}/*"
        ]
      }
    ]
  })
}
