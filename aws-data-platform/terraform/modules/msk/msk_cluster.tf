resource "aws_msk_cluster" "main" {
  cluster_name           = "${lower(var.env_code)}-${lower(var.project_code)}-msk"
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.brokers_count

  broker_node_group_info {
    instance_type = var.broker_instance_type

    storage_info {
      ebs_storage_info {
        volume_size = var.broker_ebs_volume_size
      }
    }

    client_subnets = var.private_subnet_id
    security_groups = [
      var.security_group_id
    ]
  }

  client_authentication {
    sasl {
      scram = var.kafka_sasl_scram_auth_enabled
      iam   = var.kafka_sasl_iam_auth_enabled
    }

    unauthenticated = var.kafka_unauthenticated_access_enabled
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = aws_kms_key.kms_msk.arn
  }

  configuration_info {
    arn      = aws_msk_configuration.msk.arn
    revision = aws_msk_configuration.msk.latest_revision
  }

  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = var.open_monitoring
      }
      node_exporter {
        enabled_in_broker = var.open_monitoring
      }
    }
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.msk.name
      }
    }
  }

  tags = merge(local.tags, {
    Name        = "${lower(var.env_code)}-${lower(var.project_code)}-msk"
    Environment = "${upper(var.env_code)}"
  })
}

resource "aws_msk_configuration" "msk" {
  kafka_versions = [var.kafka_version]
  name           = "${lower(var.env_code)}-${lower(var.project_code)}-msk"

  server_properties = <<PROPERTIES
auto.create.topics.enable = true
delete.topic.enable = true
num.network.threads = 5
num.io.threads = 8
socket.send.buffer.bytes = 102400
socket.request.max.bytes = 104857600
socket.receive.buffer.bytes = 102400
replica.lag.time.max.ms = 30000
num.replica.fetchers = 2
num.partitions = 1
PROPERTIES
}