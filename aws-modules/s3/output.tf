output "aws_s3_bucket__id" {
  value = values(aws_s3_bucket.this).*.id
}

output "aws_s3_bucket__arn" {
  value = values(aws_s3_bucket.this).*.arn
}

output "aws_s3_bucket__name" {
  value = values(aws_s3_bucket.this).*.bucket
}