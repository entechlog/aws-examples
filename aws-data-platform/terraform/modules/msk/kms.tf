resource "aws_kms_key" "kms_msk" {
  description = "${lower(var.env_code)}-${lower(var.project_code)}-msk"

  tags = merge(local.tags, {
    Name        = "${lower(var.env_code)}-${lower(var.project_code)}-msk"
    Environment = "${upper(var.env_code)}"
  })
}

resource "aws_kms_alias" "kms_msk" {
  name          = "alias/msk/${lower(var.env_code)}-${lower(var.project_code)}-msk"
  target_key_id = aws_kms_key.kms_msk.key_id
}