import boto3
import requests
import json
import yaml
import os
from datetime import datetime

def lambda_handler(event, context):
    print("Input event   : " + json.dumps(event))

    # Read list of location code from the config yaml
    configPath = os.environ['LAMBDA_TASK_ROOT'] + "/config/location.yml"
    print("configPath    : " + configPath)
    configContents = yaml.safe_load(open(configPath).read())

    # initialize variable
    string_date = datetime.today().strftime('%Y-%m-%d-%H-%M-%S')
    bucket_name = os.environ.get('BUCKET_NAME', 'temp')
    print("bucket_name   : " + bucket_name)

    for location_code in configContents['location-airport-code']:
        print('location_code : ' + location_code)

        # api-endpoint
        URL = 'https://wttr.in/' + location_code + '?format=j1'

        # defining a params dict for the parameters to be sent to the API
        PARAMS = {}

        # sending get request and saving the response as response object
        try:
            response = requests.get(url=URL, params=PARAMS, timeout=3)
            response.raise_for_status()
            response_json = json.loads(response.text)
        except requests.exceptions.HTTPError as errh:
            print("Http Error:", errh)
        except requests.exceptions.ConnectionError as errc:
            print("Error Connecting:", errc)
        except requests.exceptions.Timeout as errt:
            print("Timeout Error:", errt)
        except requests.exceptions.RequestException as err:
            print("OOps: Something Else", err)

        response_parsed = response_json['current_condition'][0]
        print("Weather       : ", response_parsed) 

        file_name = location_code + ".json"
        s3_path = string_date + '/' + file_name
        print("s3_path       : " + s3_path)

        s3 = boto3.resource("s3")
        s3.Bucket(bucket_name).put_object(Key=s3_path, Body=(bytes(json.dumps(response_parsed).encode('UTF-8'))))
