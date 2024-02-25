locals {
  timestamp            = timestamp()
  date                 = formatdate("YYYY-MM-DD", local.timestamp)
  resource_name_prefix = var.optional_use_env_code_flag == true ? "${lower(var.required_env_code)}-${lower(var.required_project_code)}" : "${lower(var.required_project_code)}"

  tags = { Author = "Terraform", Environment = "${upper(var.required_env_code)}" }

  landing_zone_bucket_name = "${local.resource_name_prefix}-landing-zone"
  source_bucket_name       = "${local.resource_name_prefix}-landing-zone"
  destination_bucket_name  = "${local.resource_name_prefix}-raw-zone"

  output_path = "source=${lower(var.required_app_code)}/"
}