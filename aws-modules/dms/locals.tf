locals {
  resource_name_prefix = var.use_env_code ? "${var.env_code}-${var.project_code}-${var.app_code}" : "${var.project_code}-${var.app_code}"
}
