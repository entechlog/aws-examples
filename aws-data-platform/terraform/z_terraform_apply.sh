terraform init

# aws_mskconnect_worker_configuration does not support delete, AWS issue
# aws_secretsmanager_secret deletes has a cooling period of 7 days, so delete and deployment won't work
# aws_kms_key deletes has a cooling period of 7 days, so delete and deployment won't work

terraform import module.msk.aws_mskconnect_worker_configuration.default_config arn:aws:kafkaconnect:us-east-1:582805303120:worker-configuration/default-kafka-config/96ccedaa-bd09-4f63-960b-9899241f2cbf-4
terraform import module.msk.aws_mskconnect_worker_configuration.secrets_manager_config arn:aws:kafkaconnect:us-east-1:582805303120:worker-configuration/secrets-manager-config/4f92040b-c22a-4896-aab1-56251422330b-4

terraform import module.msk.aws_secretsmanager_secret.msk arn:aws:secretsmanager:us-east-1:582805303120:secret:AmazonMSK_dev_entechlog_svc_data-kfG6Ij
terraform import module.msk.aws_secretsmanager_secret.snowflake arn:aws:secretsmanager:us-east-1:582805303120:secret:/msk/connect/dev_entechlog_snowflake-AjWnyw

terraform import module.msk.aws_kms_key.kms_msk arn:aws:kms:us-east-1:582805303120:key/a9ba0993-4d58-455a-bc37-88f550bc71b8

# terraform import module.mwaa.aws_secretsmanager_secret.env_code 
# terraform import module.mwaa.aws_secretsmanager_secret.snowflake_conn arn:aws:secretsmanager:us-east-1:582805303120:secret:airflow/connections/snowflake_conn-wUEfpq

terraform fmt -recursive
terraform apply
