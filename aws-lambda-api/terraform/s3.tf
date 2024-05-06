
# -------------------------------------------------------------------------
# S3 bucket for destination data in the target account
# -------------------------------------------------------------------------
module "destination_s3_bucket" {
  source         = "../../aws-modules/s3"
  s3_bucket_name = ["landing-zone"]
  use_env_code   = true
}

# -------------------------------------------------------------------------
# S3 bucket policy for the destination bucket
# This policy allows the Lambda function to access the destination bucket
# for operations like put, get, list, and delete objects.
# -------------------------------------------------------------------------
resource "aws_s3_bucket_policy" "lambda_bucket_policy_destination" {
  bucket = local.target_bucket_name
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