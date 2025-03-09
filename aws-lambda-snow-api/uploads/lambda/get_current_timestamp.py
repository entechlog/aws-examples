import json
import os
import boto3
import snowflake.connector
import base64
from botocore.exceptions import ClientError

def get_secret(secret_name):
    region_name = os.environ.get('AWS_REGION', 'us-west-2')
    session = boto3.session.Session()
    client = session.client(service_name='secretsmanager', region_name=region_name)
    try:
        response = client.get_secret_value(SecretId=secret_name)
    except ClientError as e:
        raise Exception("Error retrieving secret: " + str(e))
    else:
        if 'SecretString' in response:
            secret = response['SecretString']
            return json.loads(secret)
        else:
            decoded_binary = base64.b64decode(response['SecretBinary'])
            return json.loads(decoded_binary)

def get_current_timestamp(event, context):
    secret_name = os.environ.get('SNOWFLAKE_SECRET_ARN')
    secret = get_secret(secret_name)
    
    user     = secret.get('user')
    password = secret.get('password')
    account  = secret.get('account')
    
    try:
        conn = snowflake.connector.connect(
            user=user,
            password=password,
            account=account
        )
        cursor = conn.cursor()
        cursor.execute("SELECT CURRENT_TIMESTAMP()")
        result = cursor.fetchone()
        return {
            'statusCode': 200,
            'body': json.dumps({
                'timestamp': str(result[0]),
                'account': account
            })
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
    finally:
        try:
            cursor.close()
            conn.close()
        except Exception:
            pass
