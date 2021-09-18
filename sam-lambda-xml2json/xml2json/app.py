import boto3
import json
import xmltodict
import uuid
from urllib.parse import unquote_plus
import logging
import logging.config
import botocore
import os

# Logging
logging.config.fileConfig(fname='log.conf')
logger = logging.getLogger(__name__)

# initialize s3 connection
environment_code = os.environ.get('ENVIRONMENT_CODE', 'temp')
logger.info('Environment Code ~ {}'.format(environment_code))

if environment_code in ('local'):
    s3 = boto3.resource(
        's3', endpoint_url='http://host.docker.internal:4566', use_ssl=False)
else:
    s3 = boto3.resource('s3')


def xml_to_json(event):
    """
    - Loop over every s3 key in the incoming events
    - Read xml from s3
    - Convert xml into a json document
    - Write the json document back to s3
    """

    # Loops through every file uploaded
    for record in event['Records']:

        # Get bucket name and key from the event
        bucket_name = record['s3']['bucket']['name']
        key = unquote_plus(record['s3']['object']['key'])

        logger.info('Bucket Name ~ {}'.format(bucket_name))
        logger.info('Source S3 Record Key ~ {}'.format(key))

        # Temporarily download the xml file for processing
        tmpkey = key.replace('/', '')
        download_path = '/tmp/{}'.format(uuid.uuid4(), tmpkey)
        bucket = s3.Bucket(bucket_name)

        try:
            bucket.download_file(key, download_path)
            # Create the output file name
            s3_path = key.replace('xml', 'json')

            # Open the xml, covert to JSON
            with open(download_path) as xml_file:
                my_dict = xmltodict.parse(xml_file.read())
                xml_file.close()
                # Write back to S3 with the new file name
                try:
                    s3.Bucket(bucket_name).put_object(Key=s3_path, Body=(
                        bytes(json.dumps(my_dict).encode('UTF-8'))))
                    logger.info('Target S3 Record Key ~ {}'.format(s3_path))
                except ClientError as e:
                    logging.error(e)

        except botocore.exceptions.ClientError as e:
            if e.response['Error']['Code'] == "404":
                logger.error(
                    'The object {} does not exist in bucket {}'.format(key, bucket_name))
            else:
                raise

    return None


def lambda_handler(event, context):
    """
    Process incoming events
    """

    logger.info('Function Name ~ {}'.format(context.function_name))

    xml_to_json(event)
    return None
