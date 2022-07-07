# MWAA input variables

variable "mwaa_max_workers" {
  type        = number
  description = "Maximum number of MWAA workers"
  default     = 1
}

variable "mwaa_min_workers" {
  type        = number
  description = "Minimum number of MWAA workers"
  default     = 1
}

variable "mwaa_schedulers" {
  type        = number
  description = "Number of MWAA schedulers"
  default     = 2
}

# airflow.cfg values
# https://docs.aws.amazon.com/mwaa/latest/userguide/configuring-env-variables.html
variable "mwaa_airflow_configuration_options" {
  type        = map(string)
  description = "additional airflow configuration options"
  default     = { "core.lazy_load_plugins" = "False" }
}