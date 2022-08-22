import os
from airflow import DAG
from airflow.operators.dummy_operator import DummyOperator
from airflow.operators.python_operator import PythonOperator
from airflow.utils.dates import days_ago
from datetime import timedelta

dag_id = os.path.basename(__file__).replace(".py", "")

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': days_ago(2),
    'email': ['airflow@example.com'],
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5)
}

with DAG(
    dag_id=dag_id,
    default_args=default_args,
    description='DAG to print MWAA environment variables',
    schedule_interval=timedelta(days=1),
) as dag:

    def print_env_vars():
        keys = str(os.environ.keys()).split("|")
        keys.sort()
        for key in keys:
            print(key)

    get_env_vars_operator = PythonOperator(
        task_id='get_env_vars_task',
        python_callable=print_env_vars
    )

    get_env_vars_operator