-- Create the demo database
USE ROLE SYSADMIN;
CREATE OR REPLACE DATABASE DEMO_DB;

-- Create Schema
CREATE OR REPLACE SCHEMA DEMO_DB.SNOWPIPE;

-- Create storage integration
USE ROLE ACCOUNTADMIN;
CREATE OR REPLACE STORAGE INTEGRATION WEATHER_S3_INT
TYPE = EXTERNAL_STAGE
STORAGE_PROVIDER = S3
ENABLED = TRUE
STORAGE_AWS_ROLE_ARN = 'iam-role'
STORAGE_ALLOWED_LOCATIONS = ('s3://sam-lambda-weather-data/');

-- Grant access to integration
GRANT ALL ON INTEGRATION WEATHER_S3_INT TO SYSADMIN;

-- Verify the Integration
USE ROLE SYSADMIN;
SHOW INTEGRATIONS;

-- DO NOT RUN
DROP INTEGRATION WEATHER_S3_INT;

-- Describe Integration and retrieve the AWS IAM User (STORAGE_AWS_IAM_USER_ARN and STORAGE_AWS_EXTERNAL_ID) for Snowflake Account
DESC INTEGRATION WEATHER_S3_INT;

-- Grant the IAM user permissions to access S3 Bucket. 
-- Navigate to IAM in AWS console, click Roles > click your role name from cloudformation output > click Trust relationships > click Edit trust relationship > Update the Principal with STORAGE_AWS_IAM_USER_ARN and sts:ExternalId with STORAGE_AWS_EXTERNAL_ID > click Update Trust Policy. 
-- Now we have replaced the temporary details which we gave when creating the role in cloudformation with the correct snowflake account and external ID.

-- Create file format for incoming files
CREATE OR REPLACE FILE FORMAT DEMO_DB.SNOWPIPE.WEATHER_FILE_FORMAT
TYPE = JSON COMPRESSION = AUTO TRIM_SPACE = TRUE NULL_IF = ('NULL', 'NULL');

-- Verify the File Format
SHOW FILE FORMATS;

-- Create state for incoming files. Update `URL` with s3 bucket details
CREATE OR REPLACE STAGE DEMO_DB.SNOWPIPE.WEATHER_S3_STG
STORAGE_INTEGRATION = WEATHER_S3_INT
URL = 's3://sam-lambda-weather-data/'
FILE_FORMAT = WEATHER_FILE_FORMAT;

-- Verify Stage
SHOW STAGES;
LIST @DEMO_DB.SNOWPIPE.WEATHER_S3_STG

-- Create target table for JSON data
CREATE
	OR REPLACE TABLE DEMO_DB.SNOWPIPE.WEATHER_RAW_TBL (
	FILE_PATH_NAME VARCHAR(16777216),
	FILE_NAME VARCHAR(16777216),
	FILE_ROW_NUMBER NUMBER(38, 0),
	FILE_TIMESTAMP TIMESTAMP_NTZ(9),
	FILE_DT DATE,
	FILE_HOUR NUMBER(38, 0),
	ETL_LOAD_DT DATE,
	ETL_LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
	EVENT_NAME VARCHAR(16777216),
	EVENT VARIANT
	);

-- Describe table
DESC TABLE DEMO_DB.SNOWPIPE.WEATHER_RAW_TBL;

-- Create snowpipe to ingest data from `STAGE` to `TABLE`
CREATE
	OR REPLACE PIPE DEMO_DB.SNOWPIPE.WEATHER_SNOWPIPE AUTO_INGEST = TRUE AS COPY
INTO DEMO_DB.SNOWPIPE.WEATHER_RAW_TBL
FROM (
	SELECT replace(metadata$filename, split_part(metadata$filename, '/', - 1), '') AS file_path_name,
		split_part(metadata$filename, '/', - 1) AS file_name,
		metadata$file_row_number AS file_row_number,
		try_to_timestamp(left(metadata$filename, 19), 'YYYY-MM-DD-HH24-MI-SS') AS file_timestamp,
		try_to_date(left(metadata$filename, 10)) AS file_dt,
		hour(try_to_timestamp(left(metadata$filename, 19), 'YYYY-MM-DD-HH24-MI-SS')) AS file_hour,
		DATE (sysdate()) AS etl_load_dt,
		sysdate() AS etl_load_timestamp,
		split_part(split_part(split_part(metadata$filename, '/', - 1), '-', 1), '.', 1) AS event_name,
		$1::variant AS event
	FROM @DEMO_DB.SNOWPIPE.WEATHER_S3_STG
	);

-- Describe snowpipe and copy the ARN for notification_channel	
SHOW PIPES LIKE '%WEATHER_SNOWPIPE%';

-- Now is the time to connect S3 and snowpipe. 
-- Navigate to Amazon S3 > click your bucket > click Properties > click Create event notification > Update Event name, Prefix and Suffix > Set Event types as All object create events > Update Destination as SQS queue and click Enter SQS queue ARN from the snowpipe

-- Validate the snowpipe status
SELECT SYSTEM$PIPE_STATUS('DEMO_DB.SNOWPIPE.WEATHER_SNOWPIPE');

-- Validate data in snowflake
SELECT * FROM DEMO_DB.SNOWPIPE.WEATHER_RAW_TBL;

-- Pause pipe
ALTER PIPE DEMO_DB.SNOWPIPE.WEATHER_SNOWPIPE
SET PIPE_EXECUTION_PAUSED = TRUE;

-- Truncate table before reloading
TRUNCATE TABLE DEMO_DB.SNOWPIPE.WEATHER_RAW_TBL;

-- Set pipe for refresh
ALTER PIPE DEMO_DB.SNOWPIPE.WEATHER_SNOWPIPE REFRESH;

-- Create Parsed table
CREATE
	OR REPLACE TABLE DEMO_DB.SNOWPIPE.WEATHER_PARSED_TBL (
	FILE_PATH_NAME VARCHAR(16777216),
	FILE_NAME VARCHAR(16777216),
	FILE_ROW_NUMBER NUMBER(38, 0),
	FILE_TIMESTAMP TIMESTAMP_NTZ(9),
	FILE_DT DATE,
	FILE_HOUR NUMBER(38, 0),
	ETL_LOAD_DT DATE,
	ETL_LOAD_TIMESTAMP TIMESTAMP_NTZ(9),
	EVENT_NAME VARCHAR(16777216),
	"LOCALOBSDATETIME" STRING,
	"TEMP_C" STRING,
	"TEMP_F" STRING,
	"FEELSLIKEC" STRING,
	"FEELSLIKEF" STRING,
	"WEATHERDESC" STRING
	);

-- Create snowpipe for Parsed table
CREATE OR REPLACE PIPE DEMO_DB.SNOWPIPE.WEATHER_PARSED_SNOWPIPE AUTO_INGEST = TRUE AS COPY
INTO DEMO_DB.SNOWPIPE.WEATHER_PARSED_TBL
FROM (
	SELECT replace(metadata$filename, split_part(metadata$filename, '/', - 1), '') AS file_path_name,
		split_part(metadata$filename, '/', - 1) AS file_name,
		metadata$file_row_number AS file_row_number,
		try_to_timestamp(left(metadata$filename, 19), 'YYYY-MM-DD-HH24-MI-SS') AS file_timestamp,
		try_to_date(left(metadata$filename, 10)) AS file_dt,
		hour(try_to_timestamp(left(metadata$filename, 19), 'YYYY-MM-DD-HH24-MI-SS')) AS file_hour,
		DATE (sysdate()) AS etl_load_dt,
		sysdate() AS etl_load_timestamp,
		split_part(split_part(split_part(metadata$filename, '/', - 1), '-', 1), '.', 1) AS event_name,
		$1:localObsDateTime AS LOCALOBSDATETIME,
		$1:temp_C AS TEMP_C,
		$1:temp_F AS TEMP_F,
		$1:FeelsLikeC AS FEELSLIKEC,
		$1:FeelsLikeF AS FEELSLIKEF,
		$1:weatherDesc [0] ['value'] AS WEATHERDESC
	FROM @DEMO_DB.SNOWPIPE.WEATHER_S3_STG
	);

-- Validate the snowpipe status
SELECT SYSTEM$PIPE_STATUS('DEMO_DB.SNOWPIPE.WEATHER_PARSED_SNOWPIPE');

-- Validate data 
SELECT * FROM DEMO_DB.SNOWPIPE.WEATHER_RAW_TBL ORDER BY ETL_LOAD_TIMESTAMP DESC;
SELECT * FROM DEMO_DB.SNOWPIPE.WEATHER_PARSED_TBL ORDER BY ETL_LOAD_TIMESTAMP DESC;

-- CLEAN DEMO RESOURCES
USE ROLE SYSADMIN;
DROP DATABASE DEMO_DB;