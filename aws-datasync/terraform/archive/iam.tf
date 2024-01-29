# Development Account: IAM Role to be assumed by Production Account
resource "aws_iam_role" "cross_account_role" {
  name               = "${local.resource_name_prefix}-cross-account-role"
  assume_role_policy = data.aws_iam_policy_document.cross_account_role__policy_document.json
}

# Trust policy for the above role
data "aws_iam_policy_document" "cross_account_role__policy_document" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.prd.account_id}:root"]
    }
  }
}

# Production Account: IAM User
resource "aws_iam_user" "cross_account_user" {
  provider = aws.prd
  name     = "${local.resource_name_prefix}-cross-account-user"
}

# Production Account: Policy to allow the user to assume the Development role
resource "aws_iam_policy" "cross_account_assume_role_policy" {
  provider = aws.prd
  name     = "${local.resource_name_prefix}-cross-account-assume-role-policy"
  policy   = data.aws_iam_policy_document.cross_account_assume_role_policy_document.json
}

# Policy document for the above policy
data "aws_iam_policy_document" "cross_account_assume_role_policy_document" {
  statement {
    actions   = ["sts:AssumeRole"]
    effect    = "Allow"
    resources = ["arn:aws:iam::${data.aws_caller_identity.dev.account_id}:role/${aws_iam_role.cross_account_role.name}"]
  }
}

# Attach the policy to the Production user
resource "aws_iam_user_policy_attachment" "cross_account_user_policy_attachment" {
  provider   = aws.prd
  user       = aws_iam_user.cross_account_user.name
  policy_arn = aws_iam_policy.cross_account_assume_role_policy.arn
}