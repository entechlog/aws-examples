import os
from airflow import DAG
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
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    dag_id=dag_id,
    default_args=default_args,
    description='DAG to print airflow.cfg',
    schedule_interval=timedelta(days=1),
) as dag:

    def print_airflow_cfg():
        with open(f"{os.getenv('AIRFLOW_HOME')}/airflow.cfg", 'r') as airflow_cfg:
            file_contents = airflow_cfg.read()
            print(f'\n{file_contents}')

    get_airflow_cfg_operator = PythonOperator(
        task_id='get_airflow_cfg_task',
        python_callable=print_airflow_cfg
    )

    print_airflow_cfg