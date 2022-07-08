import os
from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from airflow.utils.dates import days_ago
from airflow.models import Variable
from datetime import timedelta

env_code = Variable.get("env_code", default_var="undefined")

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
    description='DAG to get variables from secrets backend',
    schedule_interval=timedelta(days=1),
) as dag:

    # Using Variable.get
    get_var_sec1 = BashOperator(
        task_id="disp_aws_secret_using_variable_get",
        bash_command='echo "The value of the variable is: {var}"'.format(
            var=env_code),
    )

    # Using Jinja template, preferred method for accessing variables
    get_var_sec2 = BashOperator(
        task_id="disp_aws_secret_using_variable_jinja",
        bash_command='echo "The value of the variable is: {{var.value.env_code}}"',
    )

    # Using Jinja template, preferred method for accessing variables
    get_var_sec3 = BashOperator(
        task_id="disp_imported_variable_jinja",
        bash_command='echo "The value of the variable is: {{var.value.dbt_target}}"',
    )
