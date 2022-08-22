# MWAA S3

resource "aws_s3_bucket" "s3_bucket" {
  bucket = "${lower(var.env_code)}-${lower(var.project_code)}-mwaa"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }

  tags = merge(local.tags, {
    Name        = "${lower(var.env_code)}-${lower(var.project_code)}-mwaa"
    Environment = "${upper(var.env_code)}"
  })
}

resource "aws_s3_bucket_public_access_block" "s3_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.s3_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_object" "dags" {
  for_each = fileset("uploads/mwaa/dags/", "*.py")
  bucket   = aws_s3_bucket.s3_bucket.id
  key      = "dags/${each.value}"
  source   = "uploads/mwaa/dags/${each.value}"
  etag     = filemd5("uploads/mwaa/dags/${each.value}")
}

resource "aws_s3_bucket_object" "requirements" {
  for_each = fileset("uploads/mwaa/requirements/", "*.txt")
  bucket   = aws_s3_bucket.s3_bucket.id
  key      = "requirements/${each.value}"
  source   = "uploads/mwaa/requirements/${each.value}"
  etag     = filemd5("uploads/mwaa/requirements/${each.value}")
}

resource "aws_s3_bucket_object" "variables" {
  for_each = fileset("uploads/mwaa/variables/", "*.json")
  bucket   = aws_s3_bucket.s3_bucket.id
  key      = "variables/${each.value}"
  source   = "uploads/mwaa/variables/${each.value}"
  etag     = filemd5("uploads/mwaa/variables/${each.value}")
}
data "archive_file" "plugins" {
  type        = "zip"
  source_dir  = "uploads/mwaa/plugins/"
  output_path = "uploads/mwaa/plugins.zip"
  excludes    = ["uploads/mwaa/plugins/.gitkeep"]
}

resource "aws_s3_bucket_object" "plugins" {
  bucket = aws_s3_bucket.s3_bucket.id
  key    = "mwaa/plugins.zip"
  source = "uploads/mwaa/plugins.zip"
}