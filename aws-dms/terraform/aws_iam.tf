# Create an IAM role for DMS
resource "aws_iam_role" "dms_role" {
  name = "dms-vpc-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "dms.amazonaws.com"
        }
      },
    ]
  })
}

# Attach the managed policy for VPC management
resource "aws_iam_role_policy_attachment" "dms_vpc_management_policy" {
  role       = aws_iam_role.dms_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
}

# Attach a policy to allow DMS to access S3
resource "aws_iam_role_policy" "dms_s3_access_policy" {
  role = aws_iam_role.dms_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:ListBucket",
          "s3:GetObject",
          "s3:GetObjectTagging",
          "s3:PutObjectTagging"
        ],
        Resource = [
          "arn:aws:s3:::${local.dms_bucket_name}",
          "arn:aws:s3:::${local.dms_bucket_name}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "rds:DescribeDBInstances",
          "rds:DescribeDBClusters"
        ],
        Resource = "*"
      }
    ]
  })
}

# Optional: Attach a policy to allow DMS to access KMS
resource "aws_iam_role_policy" "dms_kms_access_policy" {
  role = aws_iam_role.dms_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ],
        Resource = "*"
      }
    ]
  })
}

# Optional: Attach a policy to allow DMS to write logs to CloudWatch
resource "aws_iam_role_policy" "dms_cloudwatch_policy" {
  role = aws_iam_role.dms_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}
