resource "aws_cloudwatch_log_group" "msk" {
  name = "/msk/kafka-cluster/${lower(var.env_code)}-${lower(var.project_code)}-msk"

  tags = merge(local.tags, {
    Name        = "${lower(var.env_code)}-${lower(var.project_code)}-msk"
    Environment = "${upper(var.env_code)}"
  })
}

resource "aws_cloudwatch_log_group" "msk_connect" {
  name = "/msk/kafka-connect/${lower(var.env_code)}-${lower(var.project_code)}-msk"

  tags = merge(local.tags, {
    Name        = "${lower(var.env_code)}-${lower(var.project_code)}-msk"
    Environment = "${upper(var.env_code)}"
  })
}