-- Create table
CREATE TABLE breakfast_menu (
	food_name VARCHAR,
	food_price VARCHAR,
	food_description VARCHAR
	);

-- Copy JSON from S3 to Redshift table using json path
COPY breakfast_menu
FROM 's3://sam-lambda-xml2json/json/' CREDENTIALS 'aws_iam_role=<iam-role-for-redshift>' json 's3://sam-lambda-xml2json/jsonpath/jsonpath_breakfast_menu.json';

-- Validate record count
SELECT COUNT(*)
FROM breakfast_menu

-- Validate parsed JSON
SELECT *
FROM breakfast_menu
WHERE food_name IS NOT NULL;
