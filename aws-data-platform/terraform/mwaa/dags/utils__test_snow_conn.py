import os
from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from airflow.utils.dates import days_ago
from airflow.operators.python_operator import PythonOperator
from airflow.contrib.operators.snowflake_operator import SnowflakeOperator
from airflow.hooks.base import BaseHook
from datetime import timedelta

dag_id = os.path.basename(__file__).replace(".py", "")

snowflake_conn = BaseHook.get_connection('snowflake_conn')

test_query = [
    """select 1;""",
    """SHOW DATABASES;""",
]

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': days_ago(2),
    'email': ['airflow@example.com'],
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    dag_id=dag_id,
    default_args=default_args,
    description='DAG to test snowflake connection from secrets backend',
    schedule_interval=timedelta(days=1),
) as dag:

    test_snow_conn = SnowflakeOperator(
        task_id="test_snow_conn",
        sql=test_query,
        snowflake_conn_id=snowflake_conn,
    )

    test_snow_conn
