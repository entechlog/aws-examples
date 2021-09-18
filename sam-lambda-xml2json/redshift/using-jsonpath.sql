DROP TABLE run_results;

CREATE TABLE run_results (
	dbt_schema_version VARCHAR,
	dbt_version VARCHAR
	);

COPY run_results
FROM 's3://entechlog-test/run_results.json' CREDENTIALS 'aws_iam_role=arn:aws:iam::582805303120:role/dev-entechlog-redshift' json 's3://entechlog-test/jsonpaths.json';

SELECT COUNT(*)
FROM run_results

SELECT *
FROM run_results
