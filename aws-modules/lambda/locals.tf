locals {
  lambda_source_dir = var.source_dir
  lambda_files      = fileset(local.lambda_source_dir, "*.py")
  lambda_sha        = sha256(join(",", [for file in local.lambda_files : filesha256("${local.lambda_source_dir}/${file}")]))
}
