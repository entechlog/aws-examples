resource "aws_kms_key" "kms" {
  description = "${lower(var.env_code)}-${lower(var.project_code)}-msk"

  tags = merge(local.tags, {
    Name        = "${lower(var.env_code)}-${lower(var.project_code)}-msk"
    Environment = "${upper(var.env_code)}"
  })
}