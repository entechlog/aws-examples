# Create an S3 bucket in the Development account
module "s3" {
  source         = "./modules/s3"
  s3_bucket_name = ["landing-zone"]
  use_env_code   = true
}

# S3 Bucket Policy in Development Account to allow access from the Production account
resource "aws_s3_bucket_policy" "landing_zone_bucket_policy" {
  bucket = local.landing_zone_bucket_name
  policy = jsonencode({
    Statement = [
      {
        Action    = "s3:ListBucket",
        Effect    = "Allow",
        Resource  = "arn:aws:s3:::${local.landing_zone_bucket_name}",
        Principal = { AWS = aws_iam_role.cross_account_role.arn }
      },
      {
        Action    = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
        Effect    = "Allow",
        Resource  = "arn:aws:s3:::${local.landing_zone_bucket_name}/*",
        Principal = { AWS = aws_iam_role.cross_account_role.arn }
      }
    ]
  })
}