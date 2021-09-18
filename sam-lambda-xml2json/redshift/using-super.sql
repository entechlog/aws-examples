-- Create table with SUPER type
CREATE TABLE raw_event (event SUPER);

-- Copy JSON from S3 to Redshift table
COPY raw_event
FROM 's3://sam-lambda-xml2json/json/breakfast_menu.json' REGION 'us-east-1' IAM_ROLE '<iam-role-for-redshift>' FORMAT JSON 'noshred';

-- Validate record count
SELECT COUNT(*)
FROM raw_event;

-- Validate raw event
SELECT re.*
FROM raw_event re;

-- Parse the JSON
SELECT event.breakfast_menu.food [0].name,
	event.breakfast_menu.food [0].price,
	event.breakfast_menu.food [0].description
FROM raw_event;

-- Parse the JSON using PartiQL
SELECT bmf.name,
	bmf.price,
	bmf.description
FROM raw_event re,
	re.event.breakfast_menu.food bmf;

-- Create materialized view

CREATE MATERIALIZED VIEW breakfast_menu_view AUTO REFRESH YES AS
SELECT bmf.name,
	bmf.price,
	bmf.description
FROM raw_event re,
	re.event.breakfast_menu.food bmf;

SELECT * FROM breakfast_menu_view;