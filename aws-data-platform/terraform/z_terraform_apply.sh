terraform import module.msk.aws_mskconnect_worker_configuration.default_config arn:aws:kafkaconnect:us-east-1:582805303120:worker-configuration/default-config/f07e7814-18c9-4d3a-a7eb-1f5007ec9a4e-4
terraform import module.msk.aws_secretsmanager_secret.msk arn:aws:secretsmanager:us-east-1:582805303120:secret:AmazonMSK_dev_entechlog_kafka_user-hc6UON

terraform fmt -recursive
terraform init
terraform apply
