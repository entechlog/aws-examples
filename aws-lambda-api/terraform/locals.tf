locals {
  timestamp            = timestamp()
  date                 = formatdate("YYYY-MM-DD", local.timestamp)
  resource_name_prefix = var.optional_use_env_code_flag == true ? "${lower(var.required_env_code)}-${lower(var.required_project_code)}" : "${lower(var.required_project_code)}"

  tags = { Author = "Terraform", Environment = "${upper(var.required_env_code)}" }

  target_bucket_name = "${local.resource_name_prefix}-landing-zone"

}