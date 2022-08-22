import os
from airflow import DAG
from airflow.operators.bash_operator import BashOperator
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
    description='DAG to import variables from a file in json format',
    schedule_interval=timedelta(days=1),
) as dag:

    get_var_filename = BashOperator(
        task_id="get_var_filename",
        bash_command='echo "You are importing the following variable file: \'{{ dag_run.conf["var_filename"] if dag_run.conf else "variables.json" }}\'"',
    )
    
    task1 = BashOperator(
        task_id="create_variables",
        bash_command='airflow variables import /usr/local/airflow/variables/{{ dag_run.conf["var_filename"] if dag_run.conf else "variables.json"}}'
    )