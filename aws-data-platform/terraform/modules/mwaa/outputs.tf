# MWAA output variables

output "s3_bucket_id" {
  value       = aws_s3_bucket.s3_bucket.id
  description = "ID of MWAA S3 bucket"
}

output "mwaa_environment_arn" {
  value       = aws_mwaa_environment.mwaa_environment.arn
  description = "ARN of MWAA environment"
}

output "mwaa_webserver_url" {
  value       = aws_mwaa_environment.mwaa_environment.webserver_url
  description = "ARN of MWAA environment"
}
