output "aws_s3_bucket__source_bucket_name" {
  value = local.source_bucket_name
}

output "aws_iam_user__destination_cross_account_user" {
  value = aws_iam_user.destination_cross_account_user.name
}

# You might want to set this to true in production settings
output "aws_iam_user__destination_cross_account_user_key" {
  value     = aws_iam_access_key.destination_cross_account_user_key.id
  sensitive = false
}

# This ensures the actual value is not shown in the Terraform plan output
# Get value by running "terraform output aws_iam_user__destination_cross_account_user_secret"
output "aws_iam_user__destination_cross_account_user_secret" {
  value     = aws_iam_access_key.destination_cross_account_user_key.secret
  sensitive = true
}

output "aws_iam_role__source_cross_account_role" {
  value = aws_iam_role.source_cross_account_role.name
}