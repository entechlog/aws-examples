terraform import module.msk.aws_mskconnect_worker_configuration.default_config arn:aws:kafkaconnect:us-east-1:582805303120:worker-configuration/default-config/f07e7814-18c9-4d3a-a7eb-1f5007ec9a4e-4
terraform import module.msk.aws_secretsmanager_secret.msk arn:aws:secretsmanager:us-east-1:582805303120:secret:AmazonMSK_dev_entechlog_kafka_usr-1UK6mV
# terraform import module.mwaa.aws_secretsmanager_secret.env_code 
terraform import module.mwaa.aws_secretsmanager_secret.snowflake_conn arn:aws:secretsmanager:us-east-1:582805303120:secret:airflow/connections/snowflake_conn-wUEfpq

terraform fmt -recursive
terraform init
terraform apply
