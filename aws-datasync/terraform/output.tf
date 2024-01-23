output "aws_s3_bucket__id" {
  value = local.landing_zone_bucket_name
}

output "aws_iam_user__cross_account_user" {
  value = aws_iam_user.cross_account_user.name
}

output "aws_iam_role__cross_account_role" {
  value = aws_iam_role.cross_account_role.name
}