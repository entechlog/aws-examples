# -------------------------------------------------------------------------
# Variable definitions for Snowflake integration
# -------------------------------------------------------------------------
# These variables are utilized for setting up the integration between Snowflake and AWS, specifying the AWS IAM user ARN and AWS external ID.

variable "snowflake__aws_iam_user_arn" {
  type        = string
  description = "The AWS IAM user ARN from Snowflake. It allows Snowflake to assume an IAM role."
  default     = null
}

variable "snowflake_storage__aws_external_id" {
  type        = string
  description = "The AWS external ID from Snowflake, enhancing security for the trust relationship."
  default     = "12345"
}

# -------------------------------------------------------------------------
# Local values configuration
# -------------------------------------------------------------------------
# Local values simplify the management of variables and defaults, here setting a default for `snowflake__aws_iam_user_arn` if not explicitly provided.

locals {
  snowflake__aws_iam_user_arn = coalesce(var.snowflake__aws_iam_user_arn, data.aws_caller_identity.current.arn)
}

# -------------------------------------------------------------------------
# IAM Policy Document for Snowflake to Assume Role
# -------------------------------------------------------------------------
# This IAM policy document defines the conditions under which Snowflake can assume the IAM role, including a security condition based on the external ID.

data "aws_iam_policy_document" "snowflake_assume_role" {
  provider = aws.prd

  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [local.snowflake__aws_iam_user_arn]
    }
    actions = ["sts:AssumeRole"]
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.snowflake_storage__aws_external_id]
    }
  }
}

# -------------------------------------------------------------------------
# IAM Role for Snowflake to Access S3
# -------------------------------------------------------------------------
# This IAM role, assumed by Snowflake for S3 operations, is defined with an assume role policy crafted from the above document, ensuring secure access.

resource "aws_iam_role" "snowflake_s3_access_role" {
  provider = aws.prd

  name               = "${local.resource_name_prefix}-snowflake-s3-access"
  description        = "IAM role for Snowflake to securely access S3 for data storage and retrieval."
  assume_role_policy = data.aws_iam_policy_document.snowflake_assume_role.json
}

# -------------------------------------------------------------------------
# Output block for the ARN of the Snowflake S3 Access Role
# -------------------------------------------------------------------------
# This output will display the ARN of the IAM role created for Snowflake to access S3,
# making it easily retrievable for further configurations or reference.

output "snowflake_s3_access_role_arn" {
  description = "The ARN of the IAM role used by Snowflake to access S3"
  value       = aws_iam_role.snowflake_s3_access_role.arn
}
