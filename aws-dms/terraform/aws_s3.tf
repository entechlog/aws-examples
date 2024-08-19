# Create an S3 bucket for DMS replication using a module
module "dms_s3_bucket" {
  source         = "../../aws-modules/s3"
  s3_bucket_name = ["dms"]
  use_env_code   = true
}

# Attach an S3 bucket policy to allow DMS access to the bucket
resource "aws_s3_bucket_policy" "dms_s3_bucket_policy" {
  bucket = local.dms_bucket_name
  policy = jsonencode({
    Version = "2008-10-17",
    Statement = [
      {
        Sid       = "DMSS3WriteAccess",
        Effect    = "Allow",
        Principal = { AWS = aws_iam_role.dms_role.arn },
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
          "arn:aws:s3:::${local.dms_bucket_name}",
          "arn:aws:s3:::${local.dms_bucket_name}/*"
        ]
      }
    ]
  })
}
