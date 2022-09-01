// Snowflake Connector

resource "aws_mskconnect_connector" "tgt_snowflake_datagen" {
  name = "tgt-snowflake-datagen"

  kafkaconnect_version = var.kafka_connect_version

  capacity {
    autoscaling {
      mcu_count        = 1
      min_worker_count = 1
      max_worker_count = 2

      scale_in_policy {
        cpu_utilization_percentage = 20
      }

      scale_out_policy {
        cpu_utilization_percentage = 80
      }
    }
  }

  worker_configuration {
    arn      = aws_mskconnect_worker_configuration.secrets_manager_config.arn
    revision = aws_mskconnect_worker_configuration.secrets_manager_config.latest_revision
  }

  connector_configuration = {
    "connector.class"                  = "com.snowflake.kafka.connector.SnowflakeSinkConnector",
    "tasks.max"                        = "2",
    "topics"                           = "users",
    "snowflake.topic2table.map"        = "users:users",
    "buffer.count.records"             = "10000",
    "buffer.flush.time"                = "60",
    "buffer.size.bytes"                = "5000000",
    "snowflake.url.name"               = "${var.snowflake_url_name}",
    "snowflake.user.name"              = "${lower(var.env_code)}_${var.snowflake_user_name}",
    "snowflake.private.key"            = "$${secretManager:dev_entechlog_snowflake:private_key}",
    "snowflake.private.key.passphrase" = "$${secretManager:dev_entechlog_snowflake:private_key_passphrase}",
    "snowflake.database.name"          = "${upper(var.env_code)}_ENTECHLOG_RAW_DB",
    "snowflake.schema.name"            = "datagen",
    "key.converter"                    = "org.apache.kafka.connect.storage.StringConverter",
    "value.converter"                  = "org.apache.kafka.connect.json.JsonConverter",
    "value.converter.schemas.enable" : "false"
  }

  kafka_cluster {
    apache_kafka_cluster {
      bootstrap_servers = aws_msk_cluster.main.bootstrap_brokers_sasl_iam

      vpc {
        security_groups = [var.security_group_id]
        subnets         = var.private_subnet_id
      }
    }
  }

  kafka_cluster_client_authentication {
    authentication_type = "IAM"
  }

  kafka_cluster_encryption_in_transit {
    encryption_type = "TLS"
  }

  plugin {
    custom_plugin {
      arn      = aws_mskconnect_custom_plugin.snowflake.arn
      revision = aws_mskconnect_custom_plugin.snowflake.latest_revision
    }
  }

  service_execution_role_arn = aws_iam_role.msk_connect.arn

  log_delivery {
    worker_log_delivery {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.msk_connect.name
      }
    }
  }

}