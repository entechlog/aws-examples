-- Create table
CREATE TABLE raw_event (event SUPER);

COPY raw_event
FROM 's3://sam-lambda-xml2json/breakfast_menu.json' REGION 'us-east-1' IAM_ROLE 'arn:aws:iam::582805303120:role/dev-entechlog-redshift' FORMAT JSON 'noshred';

SELECT COUNT(*)
FROM raw_event;

SELECT re.*
FROM raw_event re;

SELECT event.breakfast_menu.food [0].name,
	event.breakfast_menu.food [0].price,
	event.breakfast_menu.food [0].description
FROM raw_event;

SELECT bmf.name,
	bmf.price,
	bmf.description
FROM raw_event re,
	re.event.breakfast_menu.food bmf;
