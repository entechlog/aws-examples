import os
from airflow import DAG
from airflow.operators.bash import BashOperator
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
    description='DAG to print list of Python packages',
    schedule_interval=timedelta(days=1),
) as dag:

    list_python_packages_operator = BashOperator(
        task_id="list_python_packages", bash_command="python3 -m pip list"
    )

    list_python_packages_operator
