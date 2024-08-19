locals {
  timestamp            = timestamp()
  date                 = formatdate("YYYY-MM-DD", local.timestamp)
  resource_name_prefix = var.optional_use_env_code_flag == true ? "${lower(var.required_env_code)}-${lower(var.required_project_code)}" : "${lower(var.required_project_code)}"

  tags = { Author = "Terraform", Environment = "${upper(var.required_env_code)}" }

  dms_bucket_name = module.dms_s3_bucket.aws_s3_bucket__name[0]

  output_path = "source=${lower(var.required_app_code)}/"
}