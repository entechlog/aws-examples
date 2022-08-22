# https://docs.aws.amazon.com/mwaa/latest/userguide/samples-env-variables.html
from airflow.plugins_manager import AirflowPlugin
import os

os.environ["PATH"] = os.getenv("PATH") + ":/usr/local/airflow/.local/lib/python3.7/site-packages" 
os.environ["JAVA_HOME"]="/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.272.b10-1.amzn2.0.1.x86_64"

class EnvVarPlugin(AirflowPlugin):                
     name = 'env_var_plugin'