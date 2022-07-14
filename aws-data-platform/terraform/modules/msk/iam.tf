resource "aws_iam_role" "msk_connect" {
  name = "${lower(var.env_code)}-${lower(var.project_code)}-msk-connect"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "mskConnect"
        Principal = {
          Service = [
            "kafkaconnect.amazonaws.com"
          ]
        }
      }
    ]
  })

  tags = merge(local.tags, {
    Name = "${lower(var.env_code)}-${lower(var.project_code)}-msk-connect"
  })
}

data "aws_iam_policy_document" "iam_policy_document" {

  statement {
    sid = "readS3Objects"
    actions = [
      "s3:Get*",
      "s3:List*",
      "s3-object-lambda:Get*",
    "s3-object-lambda:List*"]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    sid = "mskCluster"
    actions = [
      "kafka-cluster:Connect",
      "kafka-cluster:ReadData",
      "kafka-cluster:WriteData",
      "kafka-cluster:DescribeGroup",
      "kafka-cluster:AlterGroup",
      "kafka-cluster:WriteDataIdempotently",
      "kafka-cluster:DescribeTransactionalId",
      "kafka-cluster:AlterTransactionalId",
      "kafka-cluster:DescribeClusterDynamicConfiguration",
    "kafka-cluster:*Topic"]
    effect    = "Allow"
    resources = ["*"]
  }

}

resource "aws_iam_policy" "iam_policy" {
  name   = "${lower(var.env_code)}-${lower(var.project_code)}-msk-connect"
  path   = "/"
  policy = data.aws_iam_policy_document.iam_policy_document.json
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment" {
  role       = aws_iam_role.msk_connect.name
  policy_arn = aws_iam_policy.iam_policy.arn
}
