# Source Account: DataSync IAM Role
resource "aws_iam_role" "source_datasync_role" {
  name = "${local.resource_name_prefix}-source-datasync-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "datasync.amazonaws.com" },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

# Source Account: DataSync Read Access Policy
resource "aws_iam_policy" "source_datasync_read_policy" {
  name        = "${local.resource_name_prefix}-source-datasync-read-policy"
  description = "Policy to allow read access to the source S3 bucket"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:GetBucketLocation",
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
        Resource = ["arn:aws:s3:::${local.source_bucket_name}",
        "arn:aws:s3:::${local.source_bucket_name}/*"]
      }
    ]
  })
}

# Source Account: Attach Read Policy to DataSync Role
resource "aws_iam_role_policy_attachment" "source_datasync_read_attach" {
  role       = aws_iam_role.source_datasync_role.name
  policy_arn = aws_iam_policy.source_datasync_read_policy.arn
}

# Source Account: DataSync S3 Location
resource "aws_datasync_location_s3" "source_s3_location" {
  s3_bucket_arn = "arn:aws:s3:::${local.source_bucket_name}"
  subdirectory  = "/sample"
  s3_config { bucket_access_role_arn = aws_iam_role.source_datasync_role.arn }
}

# Destination Account: S3 Bucket
module "destination_s3_bucket_datasync" {
  source         = "./modules/s3"
  s3_bucket_name = ["demo-destination-datasync"]
  use_env_code   = true
  providers      = { aws = aws.prd }
}

# Source Account: DataSync Access Policy
resource "aws_iam_policy" "destination_datasync_access_policy" {
  name        = "${local.resource_name_prefix}-destination-datasync-access-policy"
  description = "Policy to allow DataSync to access destination S3 bucket"
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
      Resource = ["arn:aws:s3:::${local.datasync_destination_bucket_name}",
    "arn:aws:s3:::${local.datasync_destination_bucket_name}/*"] }]
  })
}

# Source Account: Attach Access Policy to DataSync Role
resource "aws_iam_role_policy_attachment" "destination_datasync_access_attach" {
  role       = aws_iam_role.source_datasync_role.name
  policy_arn = aws_iam_policy.destination_datasync_access_policy.arn
}


# Destination Account: S3 Bucket Policy
resource "aws_s3_bucket_policy" "destination_datasync_bucket_policy" {
  provider = aws.prd
  bucket   = local.datasync_destination_bucket_name
  policy = jsonencode({
    Version = "2008-10-17",
    Statement = [
      {
        Sid       = "DataSyncCreateS3LocationAndTaskAccess",
        Effect    = "Allow",
        Principal = { AWS = aws_iam_role.source_datasync_role.arn },
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
          "arn:aws:s3:::${local.datasync_destination_bucket_name}",
          "arn:aws:s3:::${local.datasync_destination_bucket_name}/*"
        ]
      },
      {
        Sid       = "DataSyncCreateS3Location",
        Effect    = "Allow",
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.dev.account_id}:root" },
        Action    = "s3:ListBucket",
        Resource  = "arn:aws:s3:::${local.datasync_destination_bucket_name}"
      }
    ]
  })
}

# Destination Account: DataSync S3 Location
resource "aws_datasync_location_s3" "destination_s3_location" {
  s3_bucket_arn = "arn:aws:s3:::${local.datasync_destination_bucket_name}"
  subdirectory  = "/sample"
  s3_config {
    bucket_access_role_arn = aws_iam_role.source_datasync_role.arn
  }
}

# Source Account: DataSync Task for On-Demand Execution
resource "aws_datasync_task" "s3_datasync_task" {
  source_location_arn      = aws_datasync_location_s3.source_s3_location.arn
  destination_location_arn = aws_datasync_location_s3.destination_s3_location.arn
  name                     = "${local.resource_name_prefix}-datasync-transfer-task"
  options {
    bytes_per_second  = -1 # No limit
    verify_mode       = "POINT_IN_TIME_CONSISTENT"
    overwrite_mode    = "ALWAYS"
    posix_permissions = "NONE"
    uid               = "NONE"
    gid               = "NONE"
    log_level         = "TRANSFER"
  }

  # Optionally, enable cloudwatch logging
  cloudwatch_log_group_arn = aws_cloudwatch_log_group.datasync_logs.arn
}

# Source Account: DataSync CloudWatch access
resource "aws_iam_policy" "datasync_logs_policy" {
  name = "${local.resource_name_prefix}-datasync-logs-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "DataSyncLogsToCloudWatchLogs",
        Effect   = "Allow",
        Action   = ["logs:PutLogEvents", "logs:CreateLogStream"],
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.datasync_logs.name}:*"
      }
    ]
  })
}


# Source Account: Attach CloudWatch Policy
resource "aws_iam_role_policy_attachment" "datasync_logs_policy_attach" {
  role       = aws_iam_role.source_datasync_role.name
  policy_arn = aws_iam_policy.datasync_logs_policy.arn
}

# Optional: CloudWatch Log Group for DataSync task logging
resource "aws_cloudwatch_log_group" "datasync_logs" {
  name = "/aws/datasync/"
}