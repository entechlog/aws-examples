# Source Account: IAM Role to be assumed by Destination Account
resource "aws_iam_role" "source_cross_account_role" {
  name               = "${local.resource_name_prefix}-source-cross-account-role"
  assume_role_policy = data.aws_iam_policy_document.source_cross_account_role_policy.json
}

# Source Account: Trust policy for the above role in Source Account
data "aws_iam_policy_document" "source_cross_account_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.destination.account_id}:root"]
    }
  }
}

# Destination Account: IAM User
resource "aws_iam_user" "destination_cross_account_user" {
  provider = aws.prd
  name     = "${local.resource_name_prefix}-destination-cross-account-user"
}

# Destination Account: IAM User Key
resource "aws_iam_access_key" "destination_cross_account_user_key" {
  provider = aws.prd
  user     = aws_iam_user.destination_cross_account_user.name
}

# Destination Account: Policy to allow the user to assume the Source role
resource "aws_iam_policy" "destination_cross_account_assume_role_policy" {
  provider = aws.prd
  name     = "${local.resource_name_prefix}-destination-cross-account-assume-role-policy"
  policy   = data.aws_iam_policy_document.destination_cross_account_assume_role_policy.json
}

# Destination Account: Policy document for the above policy in Destination Account
data "aws_iam_policy_document" "destination_cross_account_assume_role_policy" {
  statement {
    actions   = ["sts:AssumeRole"]
    effect    = "Allow"
    resources = ["arn:aws:iam::${data.aws_caller_identity.source.account_id}:role/${aws_iam_role.source_cross_account_role.name}"]
  }
}

# Destination Account: Attach the policy to the Destination user
resource "aws_iam_user_policy_attachment" "destination_user_policy_attachment" {
  provider   = aws.prd
  user       = aws_iam_user.destination_cross_account_user.name
  policy_arn = aws_iam_policy.destination_cross_account_assume_role_policy.arn
}

# Source Account: Create an S3 bucket
module "source_s3_bucket" {
  source         = "./modules/s3"
  s3_bucket_name = ["demo-source"]
  use_env_code   = true
}

# Source Account: S3 Bucket Policy to allow access from the Destination account
resource "aws_s3_bucket_policy" "source_s3_bucket_policy" {
  bucket = local.source_bucket_name
  policy = jsonencode({
    Version = "2008-10-17",
    Statement = [
      {
        Action   = "s3:ListBucket",
        Effect   = "Allow",
        Resource = "arn:aws:s3:::${local.source_bucket_name}",
        Condition = {
          StringLike = {
            "s3:prefix" = ["sample/*"]
          }
        },
        Principal = { AWS = aws_iam_role.source_cross_account_role.arn }
      },
      {
        Action    = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
        Effect    = "Allow",
        Resource  = "arn:aws:s3:::${local.source_bucket_name}/sample/*",
        Principal = { AWS = aws_iam_role.source_cross_account_role.arn }
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

# Source Account : Upload sample files
resource "aws_s3_object" "source_s3_object" {
  for_each = fileset("uploads/sample/", "*.json")
  bucket   = local.source_bucket_name
  key      = "sample/${each.value}"
  source   = "uploads/sample/${each.value}"
  etag     = filemd5("uploads/sample/${each.value}")
}

# Destination Account: Create an S3 bucket
module "destination_s3_bucket_copy" {

  providers = { aws = aws.prd }

  source         = "./modules/s3"
  s3_bucket_name = ["demo-destination-copy"]
  use_env_code   = true
}

# Source Account: Access Policy
resource "aws_iam_policy" "destination_copy_access_policy" {
  name        = "${local.resource_name_prefix}-destination-copy-access-policy"
  description = "Policy to allow copy to access destination S3 bucket"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{ Effect = "Allow",
      Action = ["s3:GetBucketLocation",
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads",
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:AbortMultipartUpload",
        "s3:ListMultipartUploadParts",
        "s3:GetObjectTagging",
      "s3:PutObjectTagging"],
      Resource = ["arn:aws:s3:::${local.copy_destination_bucket_name}",
    "arn:aws:s3:::${local.copy_destination_bucket_name}/*"] }]
  })
}

# Source Account: Attach Access Policy to IAM Role
resource "aws_iam_role_policy_attachment" "destination_copy_access_attach" {
  role       = aws_iam_role.source_cross_account_role.name
  policy_arn = aws_iam_policy.destination_copy_access_policy.arn
}

# Destination Account: S3 Bucket Policy
resource "aws_s3_bucket_policy" "destination_copy_bucket_policy" {
  provider = aws.prd
  bucket   = local.copy_destination_bucket_name
  policy = jsonencode({
    Version = "2008-10-17",
    Statement = [
      {
        Sid       = "PutObjectsAccess",
        Effect    = "Allow",
        Principal = { AWS = aws_iam_role.source_cross_account_role.arn },
        Action = [
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:AbortMultipartUpload",
          "s3:DeleteObject",
          "s3:ListMultipartUploadParts",
          "s3:PutObject",
          "s3:PutObjectTagging"
        ],
        Resource = [
          "arn:aws:s3:::${local.copy_destination_bucket_name}",
          "arn:aws:s3:::${local.copy_destination_bucket_name}/*"
        ]
      }
    ]
  })
}