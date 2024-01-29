# Create an S3 bucket in the Development account
module "source_s3_bucket" {
  source         = "./modules/s3"
  s3_bucket_name = ["demo-source"]
  use_env_code   = true
}

# S3 Bucket Policy in Development Account to allow access from the Production account
resource "aws_s3_bucket_policy" "source_s3_bucket_policy" {
  bucket = local.source_bucket_name
  policy = jsonencode({
    Version = "2008-10-17",
    Statement = [
      {
        Action    = "s3:ListBucket",
        Effect    = "Allow",
        Resource  = "arn:aws:s3:::${local.source_bucket_name}",
        Principal = { AWS = aws_iam_role.cross_account_role.arn }
      },
      {
        Action    = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
        Effect    = "Allow",
        Resource  = "arn:aws:s3:::${local.source_bucket_name}/sample/*",
        Principal = { AWS = aws_iam_role.cross_account_role.arn }
      },
      # Datasync
      {
        Action    = ["s3:Get*", "s3:List*"],
        Effect    = "Allow",
        Resource  = "arn:aws:s3:::${local.source_bucket_name}/sample/*",
        Principal = { AWS = aws_iam_role.source_datasync_role.arn }
      }
    ]
  })
}

resource "aws_s3_object" "source_s3_object" {
  for_each = fileset("uploads/sample/", "*.json")
  bucket   = local.source_bucket_name
  key      = "sample/${each.value}"
  source   = "uploads/sample/${each.value}"
  etag     = filemd5("uploads/sample/${each.value}")
}