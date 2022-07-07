resource "aws_mwaa_environment" "mwaa_environment" {
  airflow_configuration_options = var.mwaa_airflow_configuration_options
  source_bucket_arn             = aws_s3_bucket.s3_bucket.arn
  dag_s3_path                   = "dags"
  execution_role_arn            = aws_iam_role.iam_role.arn
  name                          = "${lower(var.env_code)}-${lower(var.project_code)}-mwaa"
  min_workers                   = var.mwaa_min_workers
  max_workers                   = var.mwaa_max_workers
  schedulers                    = var.mwaa_schedulers
  webserver_access_mode         = "PUBLIC_ONLY"
  environment_class             = "mw1.small"
  requirements_s3_path          = "requirements.txt"

  network_configuration {
    security_group_ids = [var.security_group_id]
    subnet_ids         = [var.private_subnet_id[0], var.private_subnet_id[1]]
  }

  logging_configuration {
    dag_processing_logs {
      enabled   = true
      log_level = "INFO"
    }

    scheduler_logs {
      enabled   = true
      log_level = "INFO"
    }

    task_logs {
      enabled   = true
      log_level = "INFO"
    }

    webserver_logs {
      enabled   = true
      log_level = "INFO"
    }

    worker_logs {
      enabled   = true
      log_level = "INFO"
    }
  }
}
