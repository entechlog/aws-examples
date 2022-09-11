resource "aws_mskconnect_worker_configuration" "default_config" {
  name                    = "default-kafka-config"
  properties_file_content = <<EOT
key.converter=org.apache.kafka.connect.storage.StringConverter
value.converter=org.apache.kafka.connect.storage.StringConverter
offset.storage.topic=__consumer_offsets
EOT
}

resource "aws_mskconnect_worker_configuration" "secrets_manager_config" {
  name                    = "secrets-manager-config"
  properties_file_content = <<EOT
key.converter=org.apache.kafka.connect.storage.StringConverter
value.converter=org.apache.kafka.connect.storage.StringConverter
offset.storage.topic=__consumer_offsets
config.providers.secretManager.class=com.github.jcustenborder.kafka.config.aws.SecretsManagerConfigProvider
config.providers=secretManager
config.providers.secretManager.param.aws.region=${var.aws_region}
EOT
}