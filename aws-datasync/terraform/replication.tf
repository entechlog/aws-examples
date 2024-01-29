# Source Account: Replication IAM Role
resource "aws_iam_role" "source_replication_role" {
  name = "${local.resource_name_prefix}-source-replication-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "s3.amazonaws.com" },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

# Source Account: Replication Access Policy Document
data "aws_iam_policy_document" "source_replication_policy_document" {
  statement {
    sid    = "SourceBucketPermissions"
    effect = "Allow"

    actions = [
      "s3:GetObjectRetention",
      "s3:GetObjectVersionTagging",
      "s3:GetObjectVersionAcl",
      "s3:ListBucket",
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectLegalHold",
      "s3:GetReplicationConfiguration"
    ]

    resources = [
      "arn:aws:s3:::${local.source_bucket_name}/*",
      "arn:aws:s3:::${local.source_bucket_name}"
    ]
  }

  statement {
    sid    = "DestinationBucketPermissions"
    effect = "Allow"

    actions = [
      "s3:ReplicateObject",
      "s3:ObjectOwnerOverrideToBucketOwner",
      "s3:GetObjectVersionTagging",
      "s3:ReplicateTags",
      "s3:ReplicateDelete"
    ]

    resources = ["arn:aws:s3:::${local.replication_destination_bucket_name}/*"]
  }
}

# Source Account: Replication Access Policy
resource "aws_iam_policy" "source_replication_policy" {
  name   = "${local.resource_name_prefix}-source-replication-policy"
  policy = data.aws_iam_policy_document.source_replication_policy_document.json
}

# Source Account: Attach Replication Policy to Replication Role
resource "aws_iam_role_policy_attachment" "source_replication_policy_attach" {
  role       = aws_iam_role.source_replication_role.name
  policy_arn = aws_iam_policy.source_replication_policy.arn
}

# Destination Account: S3 Bucket
module "destination_s3_bucket_replication" {
  source         = "./modules/s3"
  s3_bucket_name = ["demo-destination-replication"]
  use_env_code   = true
  providers      = { aws = aws.prd }
}

# Destination Account: S3 Bucket Policy
resource "aws_s3_bucket_policy" "destination_replication_bucket_policy" {
  provider = aws.prd
  bucket   = local.replication_destination_bucket_name

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "PolicyForDestinationBucket",
    Statement = [
      {
        Sid    = "ReplicationPermissions",
        Effect = "Allow",
        Principal = {
          AWS = "${aws_iam_role.source_replication_role.arn}"
        },
        Action = [
          "s3:ReplicateDelete",
          "s3:ReplicateObject",
          "s3:ObjectOwnerOverrideToBucketOwner",
          "s3:GetBucketVersioning",
          "s3:PutBucketVersioning"
        ],
        Resource = [
          "arn:aws:s3:::${local.replication_destination_bucket_name}/*",
          "arn:aws:s3:::${local.replication_destination_bucket_name}"
        ]
      }
    ]
  })
}

# Source Account:
resource "aws_s3_bucket_replication_configuration" "source_s3_bucket_replication_configuration" {

  role   = aws_iam_role.source_replication_role.arn
  bucket = local.source_bucket_name

  rule {
    id = "sample"

    filter {
      prefix = "sample/"
    }

    status = "Enabled"

    delete_marker_replication {
      status = "Enabled" # or "Disabled" depending on your requirement
    }

    destination {
      bucket        = "arn:aws:s3:::${local.replication_destination_bucket_name}"
      storage_class = "STANDARD"
    }
  }
}