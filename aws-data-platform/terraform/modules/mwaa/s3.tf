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
  for_each = fileset("mwaa/dags/", "*.py")
  bucket   = aws_s3_bucket.s3_bucket.id
  key      = "dags/${each.value}"
  source   = "mwaa/dags/${each.value}"
  etag     = filemd5("mwaa/dags/${each.value}")
}

resource "aws_s3_bucket_object" "requirements" {
  for_each = fileset("mwaa/requirements/", "*.txt")
  bucket   = aws_s3_bucket.s3_bucket.id
  key      = "requirements/${each.value}"
  source   = "mwaa/requirements/${each.value}"
  etag     = filemd5("mwaa/requirements/${each.value}")
}

resource "aws_s3_bucket_object" "variables" {
  for_each = fileset("mwaa/variables/", "*.json")
  bucket   = aws_s3_bucket.s3_bucket.id
  key      = "variables/${each.value}"
  source   = "mwaa/variables/${each.value}"
  etag     = filemd5("mwaa/variables/${each.value}")
}
data "archive_file" "plugins" {
  type        = "zip"
  source_dir  = "mwaa/plugins/"
  output_path = "mwaa/plugins.zip"
  excludes    = ["mwaa/plugins/.gitkeep"]
}

resource "aws_s3_bucket_object" "plugins" {
  bucket = aws_s3_bucket.s3_bucket.id
  key    = "mwaa/plugins.zip"
  source = "mwaa/plugins.zip"
}