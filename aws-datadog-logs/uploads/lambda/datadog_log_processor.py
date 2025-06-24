import json
import boto3
import os
import uuid
import logging
from datetime import datetime, timezone
from dateutil import parser

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize Firehose client
firehose = boto3.client('firehose')

def lambda_handler(event, context):
    """
    Unified Datadog log processor for both S3 and Snowflake destinations
    Supports event-based processing, filtering, and enhanced timestamp extraction
    """
    try:
        # Get environment variables
        delivery_stream_name = os.environ.get('FIREHOSE_DELIVERY_STREAM')
        destination_type = os.environ.get('DESTINATION_TYPE', 's3')
        event_name = os.environ.get('EVENT_NAME', 'unknown')
        table_name = os.environ.get('TABLE_NAME', event_name.upper())
        apply_filters = os.environ.get('APPLY_FILTERS', 'false').lower() == 'true'
        log_filters = json.loads(os.environ.get('LOG_FILTERS', '[]')) if apply_filters else []
        
        if not delivery_stream_name:
            logger.error("FIREHOSE_DELIVERY_STREAM environment variable not set")
            return error_response("Configuration error")

        # Log incoming event for debugging
        logger.info(f"Processing {event_name} for {destination_type} - Received event with {len(event.get('body', ''))} characters")
        
        # Validate request body
        if 'body' not in event:
            return error_response("No body in request")
        
        # Parse the incoming body
        try:
            body = json.loads(event['body'])
        except json.JSONDecodeError as e:
            logger.error(f"Failed to parse JSON: {str(e)}")
            return error_response("Invalid JSON in request body")
        
        # Handle both single log and array of logs from Datadog
        log_entries = body if isinstance(body, list) else [body]
        
        if not log_entries:
            return error_response("No log entries found")
        
        # Filter logs based on configured filters (only if explicitly enabled)
        if apply_filters and log_filters:
            logger.info(f"Applying filters: {log_filters}")
            filtered_entries = []
            for log_entry in log_entries:
                if should_process_log(log_entry, log_filters):
                    filtered_entries.append(log_entry)
            
            logger.info(f"Filtered from {len(log_entries)} to {len(filtered_entries)} entries")
            log_entries = filtered_entries
            
            if not log_entries:
                return success_response(0, 0, destination_type, event_name, "No entries matched filters")
        else:
            logger.info(f"Processing all {len(log_entries)} entries without filtering")
        
        # Process logs in batches for efficiency
        batch_size = 500  # Firehose PutRecordBatch limit
        processed_count = 0
        failed_count = 0
        
        for i in range(0, len(log_entries), batch_size):
            batch = log_entries[i:i + batch_size]
            records = []
            
            for log_entry in batch:
                # Extract timestamp from log entry
                event_timestamp, event_date = extract_timestamp(log_entry)
                
                # Add processing metadata
                enriched_log = {
                    **log_entry,
                    'processed_timestamp': datetime.now(timezone.utc).isoformat(),
                    'lambda_request_id': context.aws_request_id,
                    'pipeline': f'datadog-{destination_type}',
                    'event_name': event_name,
                    'event_timestamp': event_timestamp,
                    'event_date': event_date
                }
                
                # Convert to JSON string with newline
                log_data = json.dumps(enriched_log) + '\n'
                
                records.append({'Data': log_data})
            
            # Send batch to Firehose
            if records:
                try:
                    response = firehose.put_record_batch(
                        DeliveryStreamName=delivery_stream_name,
                        Records=records
                    )
                    
                    batch_failed = response.get('FailedPutCount', 0)
                    batch_success = len(records) - batch_failed
                    
                    processed_count += batch_success
                    failed_count += batch_failed
                    
                    logger.info(f"{event_name} batch processed: {batch_success} success, {batch_failed} failed")
                    
                    # Log detailed errors
                    if batch_failed > 0:
                        for idx, record_response in enumerate(response.get('RequestResponses', [])):
                            if 'ErrorCode' in record_response:
                                logger.error(f"{event_name} record {idx} failed: {record_response['ErrorCode']} - {record_response.get('ErrorMessage', 'Unknown error')}")
                
                except Exception as e:
                    logger.error(f"Firehose batch error ({event_name}): {str(e)}")
                    failed_count += len(records)
        
        return success_response(processed_count, failed_count, destination_type, event_name)
    
    except Exception as e:
        logger.error(f"Unexpected error in {event_name} pipeline: {str(e)}", exc_info=True)
        return error_response("Internal server error")

def extract_timestamp(log_entry):
    """
    Extract timestamp from log entry and convert to UTC
    Returns tuple: (ISO timestamp, date string)
    """
    try:
        # Try different timestamp fields from Datadog
        timestamp_fields = ['timestamp', '@timestamp', 'date', 'time']
        
        for field in timestamp_fields:
            if field in log_entry:
                timestamp_value = log_entry[field]
                
                # Handle different timestamp formats
                if isinstance(timestamp_value, (int, float)):
                    # Unix timestamp (seconds or milliseconds)
                    if timestamp_value > 1e10:  # Milliseconds
                        dt = datetime.fromtimestamp(timestamp_value / 1000, tz=timezone.utc)
                    else:  # Seconds
                        dt = datetime.fromtimestamp(timestamp_value, tz=timezone.utc)
                elif isinstance(timestamp_value, str):
                    # ISO string or other formats
                    dt = parser.parse(timestamp_value)
                    if dt.tzinfo is None:
                        dt = dt.replace(tzinfo=timezone.utc)
                    else:
                        dt = dt.astimezone(timezone.utc)
                else:
                    continue
                
                # Return ISO format and date
                return dt.isoformat(), dt.strftime('%Y-%m-%d')
        
        # Fallback to current time if no timestamp found
        now = datetime.now(timezone.utc)
        return now.isoformat(), now.strftime('%Y-%m-%d')
        
    except Exception as e:
        logger.warning(f"Failed to extract timestamp: {str(e)}, using current time")
        now = datetime.now(timezone.utc)
        return now.isoformat(), now.strftime('%Y-%m-%d')

def should_process_log(log_entry, log_filters):
    """
    Check if log entry matches any of the configured filters
    Filters format: ["service:user-service", "source:authentication", "level:error"]
    """
    if not log_filters:
        return True
    
    try:
        for filter_rule in log_filters:
            if ':' not in filter_rule:
                continue
                
            field, expected_value = filter_rule.split(':', 1)
            
            # Check different possible field locations
            actual_value = None
            
            # Direct field check
            if field in log_entry:
                actual_value = log_entry[field]
            # Check in nested attributes
            elif 'attributes' in log_entry and field in log_entry['attributes']:
                actual_value = log_entry['attributes'][field]
            # Check in tags
            elif 'tags' in log_entry:
                if isinstance(log_entry['tags'], dict) and field in log_entry['tags']:
                    actual_value = log_entry['tags'][field]
                elif isinstance(log_entry['tags'], list):
                    # Tags as array: ["service:user-service", "env:prod"]
                    for tag in log_entry['tags']:
                        if isinstance(tag, str) and tag.startswith(f"{field}:"):
                            actual_value = tag.split(':', 1)[1]
                            break
            
            # If we found a match, include this log
            if actual_value and str(actual_value).lower() == expected_value.lower():
                return True
        
        return False  # No filters matched
        
    except Exception as e:
        logger.warning(f"Error processing filters: {str(e)}, including log by default")
        return True

def success_response(processed_count, failed_count, destination_type, event_name, message=None):
    """Create success response"""
    if message is None:
        message = f'Successfully processed {processed_count} {event_name} log entries to {destination_type}'
    
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json'
        },
        'body': json.dumps({
            'status': 'success',
            'destination': destination_type,
            'event_name': event_name,
            'processed_count': processed_count,
            'failed_count': failed_count,
            'message': message
        })
    }

def error_response(message):
    """Create error response"""
    return {
        'statusCode': 400,
        'headers': {
            'Content-Type': 'application/json'
        },
        'body': json.dumps({
            'status': 'error',
            'message': message
        })
    }