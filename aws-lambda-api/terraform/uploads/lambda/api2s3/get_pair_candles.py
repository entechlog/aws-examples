import json
import boto3
import requests
import sys
from datetime import datetime, timedelta
from loguru import logger

# Initialize S3 client
s3 = boto3.client('s3')

def calculate_time_interval(freq, base_time=None):
    """Calculate the start and end times based on the given frequency and optional base time."""
    if base_time:
        try:
            current_time = datetime.strptime(base_time, '%Y-%m-%dT%H:%M:%SZ')
        except ValueError:
            raise ValueError("Invalid format for BATCH_TIMESTAMP. Please use YYYY-MM-DDTHH:MM:SSZ format.")
    else:
        current_time = datetime.utcnow()

    if 'm' in freq:
        minutes = int(freq[:-1])
        start_time = current_time - timedelta(minutes=current_time.minute % minutes,
                                              seconds=current_time.second,
                                              microseconds=current_time.microsecond)
        end_time = start_time + timedelta(minutes=minutes) - timedelta(seconds=1)
    elif 'h' in freq:
        hours = int(freq[:-1])
        start_time = current_time.replace(minute=0, second=0, microsecond=0) - timedelta(hours=hours)
        end_time = start_time + timedelta(hours=hours) - timedelta(seconds=1)
    elif 'd' in freq:
        start_time = current_time.replace(hour=0, minute=0, second=0, microsecond=0) - timedelta(days=1)
        end_time = current_time.replace(hour=0, minute=0, second=0, microsecond=0) - timedelta(seconds=1)
    else:
        raise ValueError(f"Unsupported frequency: {freq}")

    return start_time, end_time

def lambda_handler(event, context):
    logger.remove()  # Remove all handlers associated with the logger
    logger.add(sys.stdout, format="{time} {level} {message}")

    # API parameters
    BASE_URL = event['BASE_URL']
    ENDPOINT = event['ENDPOINT']
    FREQUENCY = event['FREQUENCY']
    PAGE_SIZE = event['PAGE_SIZE']
    S3_BUCKET = event['S3_BUCKET']
    S3_KEY_PREFIX = event['S3_KEY_PREFIX']
    BATCH_TIMESTAMP = event.get('BATCH_TIMESTAMP', None)  # Optional batch timestamp for data ingestion

    # Dynamically calculate start and end times based on frequency
    start_time, end_time = calculate_time_interval(FREQUENCY, BATCH_TIMESTAMP)
    start_time_str = start_time.strftime('%Y-%m-%dT%H:%M:%SZ')
    end_time_str = end_time.strftime('%Y-%m-%dT%H:%M:%SZ')

    # Calculate current timestamp for filename
    current_timestamp = datetime.utcnow().strftime('%Y%m%d%H%M%S')

    # Build URL
    url = f"{BASE_URL}{ENDPOINT}?pairs=*&frequency={FREQUENCY}&page_size={PAGE_SIZE}&start_time={start_time_str}&end_time={end_time_str}"
    logger.info(f"Now processing: {url}")

    try:
        response = requests.get(url, timeout=20)
        response.raise_for_status()
        logger.info(f"Response status code: {response.status_code}")
    except requests.RequestException as e:
        logger.error(f"Failed to fetch data from API: {e}")
        return {'statusCode': 500, 'body': json.dumps('Internal server error while fetching data')}

    data = response.json()

    # Formatting the directory and file name
    event_type_dir = f"/event_type={FREQUENCY}/"  # Dynamic directory based on frequency
    directory_name = f"{event_type_dir}year={start_time.strftime('%Y')}/month={start_time.strftime('%m')}/day={start_time.strftime('%d')}/"
    formatted_endpoint = ENDPOINT.strip('/').replace('-', '_')
    # Filename with special characters removed for timestamp parts
    filename_time_start = start_time.strftime('%Y%m%dT%H%M%S')
    filename_time_end = end_time.strftime('%Y%m%dT%H%M%S')
    filename = f"{formatted_endpoint}_{FREQUENCY}_{filename_time_start}_{filename_time_end}_{current_timestamp}.json"
    s3_key = f"{S3_KEY_PREFIX}{directory_name}{filename}"

    try:
        logger.info(f"Writing to S3 at {S3_BUCKET}/{s3_key}")
        result = s3.put_object(Bucket=S3_BUCKET, Key=s3_key, Body=json.dumps(data))
        logger.info(f"Write operation status: {result['ResponseMetadata']['HTTPStatusCode']}")
    except Exception as e:
        logger.error(f"Failed to write data to S3: {e}")
        return {'statusCode': 500, 'body': json.dumps('Internal server error while writing data')}

    return {'statusCode': 200, 'body': json.dumps('Successfully processed and stored data')}
