--Create the demo database
USE ROLE SYSADMIN;

CREATE OR REPLACE DATABASE TST_ENTECHLOG_RAW_DB;
CREATE OR REPLACE SCHEMA TST_ENTECHLOG_RAW_DB.DYNAMODB;

--Create storage integration
USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE STORAGE INTEGRATION RAW_DATA_STR_S3_INTG
TYPE = EXTERNAL_STAGE
STORAGE_PROVIDER = S3
ENABLED = TRUE
STORAGE_AWS_ROLE_ARN = 'iam-role'
STORAGE_ALLOWED_LOCATIONS = ('s3://bucket-name/');

GRANT ALL ON INTEGRATION RAW_DATA_STR_S3_INTG TO SYSADMIN;

USE ROLE SYSADMIN;

SHOW INTEGRATIONS;
DESC INTEGRATION RAW_DATA_STR_S3_INTG;

--Create file format
CREATE OR REPLACE FILE FORMAT TST_ENTECHLOG_RAW_DB.DYNAMODB.JSON_FF
TYPE = JSON COMPRESSION = AUTO TRIM_SPACE = TRUE NULL_IF = ('NULL', 'NULL');

SHOW FILE FORMATS;

--Create stage
CREATE OR REPLACE STAGE TST_ENTECHLOG_RAW_DB.DYNAMODB.RAW_DATA_S3_STG
STORAGE_INTEGRATION = RAW_DATA_STR_S3_INTG
URL = 's3://bucket-name/'
FILE_FORMAT = JSON_FF;

SHOW STAGES;
LIST @TST_ENTECHLOG_RAW_DB.DYNAMODB.RAW_DATA_S3_STG;

-- Create warehouse
CREATE OR REPLACE WAREHOUSE TST_ENTECHLOG_QUERY_WH_XS
WITH 
WAREHOUSE_SIZE = 'XSMALL' 
WAREHOUSE_TYPE = 'STANDARD' 
AUTO_SUSPEND = 60 
AUTO_RESUME = TRUE 
MIN_CLUSTER_COUNT = 1 
MAX_CLUSTER_COUNT = 1 
SCALING_POLICY = 'ECONOMY' 
COMMENT = 'Warehouse for General queries';

--Query data
select
    replace(
        metadata$filename, split_part(metadata$filename, '/', -1), ''
    ) as file_path,
    split_part(metadata$filename, '/', -1) as file_name,
    metadata$file_row_number as file_row_number,
    metadata$file_content_key as file_content_key,
    metadata$file_last_modified as file_last_modified_timestamp,
    try_to_date(to_varchar(metadata$file_last_modified)) as file_last_modified_dt,
    hour(metadata$file_last_modified) as file_last_modified_hour,
    metadata$start_scan_time as loaded_timestamp,
    --'{{ this.name }}' as loaded_by,
    $1:Item:GameTitle,
    $1:Item:Score,
    $1:Item:UserId
from @TST_ENTECHLOG_RAW_DB.DYNAMODB.RAW_DATA_S3_STG;
