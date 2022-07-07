resource "aws_cloudwatch_log_group" "msk" {
  name              = "/msk/cluster/${lower(var.env_code)}-${lower(var.project_code)}-msk"
  retention_in_days = 90

  tags = merge(local.tags, {
    Name        = "${lower(var.env_code)}-${lower(var.project_code)}-msk"
    Environment = "${upper(var.env_code)}"
  })
}

resource "aws_cloudwatch_log_group" "msk_connect" {
  name              = "/msk/connect/${lower(var.env_code)}-${lower(var.project_code)}-msk"
  retention_in_days = 90

  tags = merge(local.tags, {
    Name        = "${lower(var.env_code)}-${lower(var.project_code)}-msk"
    Environment = "${upper(var.env_code)}"
  })
}