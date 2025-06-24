#!/usr/bin/env python3
"""
Enhanced Datadog Log Generator
Generates logs directly to Datadog which will then forward to your API endpoint
Supports multiple event types and realistic log patterns
"""

import json
import time
import random
import requests
from datetime import datetime
import argparse
import uuid
import sys
from typing import Dict, List, Optional

class EnhancedDatadogLogGenerator:
    def __init__(self, dd_api_key: str, dd_site: str = "datadoghq.com"):
        """
        Initialize Datadog Log Generator
        
        Args:
            dd_api_key: Your Datadog API key
            dd_site: Datadog site (datadoghq.com, datadoghq.eu, us3.datadoghq.com, etc.)
        """
        self.dd_api_key = dd_api_key
        self.dd_url = f"https://http-intake.logs.{dd_site}/v1/input/{dd_api_key}"
        
        self.session = requests.Session()
        self.session.headers.update({
            'Content-Type': 'application/json',
            'DD-API-KEY': dd_api_key
        })
        
        # Enhanced realistic data for different event types
        self.event_patterns = {
            'user-events': {
                'services': ['web-app', 'mobile-app', 'auth-service'],
                'levels': ['INFO', 'DEBUG', 'WARN', 'ERROR'],
                'level_weights': [60, 25, 10, 5],
                'messages': [
                    "User login successful",
                    "User profile updated", 
                    "Password changed",
                    "User registration completed",
                    "Session expired",
                    "Two-factor authentication enabled",
                    "User preferences saved",
                    "Account verification sent"
                ]
            },
            'system-events': {
                'services': ['database', 'cache', 'queue', 'monitoring'],
                'levels': ['INFO', 'DEBUG', 'WARN', 'ERROR'],
                'level_weights': [40, 30, 20, 10],
                'messages': [
                    "System health check passed",
                    "Database connection pool exhausted",
                    "Cache invalidation triggered",
                    "Background job completed",
                    "System backup initiated",
                    "Configuration reload detected",
                    "Memory usage threshold exceeded",
                    "Service dependency check failed"
                ]
            },
            'api-events': {
                'services': ['api-gateway', 'auth-api', 'payment-api', 'notification-api'],
                'levels': ['INFO', 'DEBUG', 'WARN', 'ERROR'], 
                'level_weights': [50, 20, 20, 10],
                'messages': [
                    "API request processed successfully",
                    "Rate limit exceeded for client",
                    "Authentication token validated",
                    "Payment processed successfully",
                    "Webhook delivery failed",
                    "API version deprecated warning",
                    "Request validation failed",
                    "Timeout occurred processing request"
                ]
            }
        }
        
        self.hosts = ['prod-web-01', 'prod-web-02', 'prod-api-01', 'prod-api-02', 'prod-db-01']
        self.environments = ['production', 'staging', 'development']

    def generate_log(self, event_type: str = 'user-events') -> dict:
        """Generate a single log entry for specified event type"""
        pattern = self.event_patterns.get(event_type, self.event_patterns['user-events'])
        
        service = random.choice(pattern['services'])
        host = random.choice(self.hosts)
        level = random.choices(pattern['levels'], weights=pattern['level_weights'])[0]
        message = random.choice(pattern['messages'])
        environment = random.choice(self.environments) if random.random() < 0.1 else 'production'
        
        # Generate realistic attributes based on log level
        attributes = {
            "request_id": str(uuid.uuid4()),
            "version": f"1.{random.randint(0, 5)}.{random.randint(0, 10)}",
            "environment": environment,
            "user_id": f"user_{random.randint(1000, 9999)}",
            "session_id": uuid.uuid4().hex[:16]
        }
        
        # Add error-specific attributes
        if level == 'ERROR':
            attributes.update({
                "error_code": random.choice([400, 401, 403, 404, 500, 502, 503]),
                "error_type": random.choice(["ValidationError", "DatabaseError", "AuthError", "TimeoutError"]),
                "stack_trace": f"Error at line {random.randint(10, 500)} in {service}.py"
            })
        elif level == 'WARN':
            attributes.update({
                "warning_type": random.choice(["PerformanceWarning", "DeprecationWarning", "SecurityWarning"]),
                "threshold_value": random.randint(80, 95)
            })
        
        # Add performance metrics for some logs
        if random.random() < 0.3:
            attributes.update({
                "response_time_ms": random.randint(50, 2000),
                "memory_usage_mb": random.randint(100, 1000),
                "cpu_usage_percent": random.randint(5, 85)
            })
        
        log_entry = {
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "level": level,
            "message": f"{message} - ID: {uuid.uuid4().hex[:8]}",
            "service": service,
            "host": host,
            "ddsource": "enhanced-python-generator",
            "ddtags": f"env:{environment},service:{service},event_type:{event_type},generator:true",
            "attributes": attributes
        }
        
        return log_entry

    def send_logs_to_datadog(self, logs: List[dict]) -> dict:
        """Send logs to Datadog with enhanced error handling"""
        try:
            response = self.session.post(self.dd_url, json=logs, timeout=30)
            return {
                'success': response.status_code == 200,
                'status_code': response.status_code,
                'response': response.text[:200] if response.text else "Empty response",
                'log_count': len(logs),
                'response_headers': dict(response.headers)
            }
        except requests.exceptions.Timeout:
            return {
                'success': False,
                'error': 'Request timeout',
                'log_count': len(logs)
            }
        except requests.exceptions.ConnectionError:
            return {
                'success': False,
                'error': 'Connection error - check network/API key',
                'log_count': len(logs)
            }
        except Exception as e:
            return {
                'success': False,
                'error': str(e),
                'log_count': len(logs)
            }

    def run_generator(self, total_logs: int, logs_per_second: int, batch_size: int = 100, event_type: str = 'user-events'):
        """
        Generate and send logs to Datadog
        
        Args:
            total_logs: Total number of logs to generate
            logs_per_second: Rate of log generation  
            batch_size: Number of logs per batch
            event_type: Type of events to generate
        """
        print(f"🐕 Enhanced Datadog Log Generator")
        print(f"📊 Configuration:")
        print(f"   • Datadog URL: {self.dd_url}")
        print(f"   • Event Type: {event_type}")
        print(f"   • Total Logs: {total_logs:,}")
        print(f"   • Rate: {logs_per_second} logs/second")
        print(f"   • Batch Size: {batch_size}")
        print(f"   • Estimated Time: {total_logs / logs_per_second:.1f} seconds")
        print("-" * 60)
        
        logs_sent = 0
        successful_logs = 0
        failed_logs = 0
        start_time = time.time()
        last_progress_time = start_time
        
        # Calculate timing
        batch_interval = batch_size / logs_per_second
        
        try:
            while logs_sent < total_logs:
                batch_start_time = time.time()
                
                # Generate batch (adjust size for last batch)
                current_batch_size = min(batch_size, total_logs - logs_sent)
                batch_logs = [self.generate_log(event_type) for _ in range(current_batch_size)]
                
                # Send to Datadog
                result = self.send_logs_to_datadog(batch_logs)
                
                # Update counters
                logs_sent += current_batch_size
                if result['success']:
                    successful_logs += current_batch_size
                    status = "✅ SUCCESS"
                else:
                    failed_logs += current_batch_size
                    status = f"❌ FAILED ({result.get('status_code', 'N/A')})"
                    if 'error' in result:
                        print(f"   Error details: {result['error']}")
                
                # Progress info (every 5 seconds or every batch if slow)
                current_time = time.time()
                if current_time - last_progress_time >= 5.0 or batch_interval >= 5.0:
                    elapsed = current_time - start_time
                    actual_rate = logs_sent / elapsed if elapsed > 0 else 0
                    progress = (logs_sent / total_logs) * 100
                    eta_seconds = (total_logs - logs_sent) / actual_rate if actual_rate > 0 else 0
                    
                    print(f"[{progress:5.1f}%] Sent {logs_sent:5,}/{total_logs:,} logs | "
                          f"{current_batch_size:3d} in batch | {status} | "
                          f"Rate: {actual_rate:5.1f}/s | ETA: {eta_seconds:3.0f}s")
                    
                    last_progress_time = current_time
                
                # Wait to maintain rate
                batch_duration = time.time() - batch_start_time
                if batch_duration < batch_interval:
                    time.sleep(batch_interval - batch_duration)
                    
        except KeyboardInterrupt:
            print(f"\n⚠️  Generation stopped by user")
        except Exception as e:
            print(f"\n❌ Unexpected error: {e}")
        
        # Final stats
        total_time = time.time() - start_time
        final_rate = logs_sent / total_time if total_time > 0 else 0
        
        print("-" * 60)
        print(f"📈 Final Results:")
        print(f"   • Event Type: {event_type}")
        print(f"   • Logs Sent: {logs_sent:,}")
        print(f"   • Successful: {successful_logs:,}")
        print(f"   • Failed: {failed_logs:,}")
        print(f"   • Success Rate: {(successful_logs/logs_sent)*100:.1f}%")
        print(f"   • Actual Rate: {final_rate:.1f} logs/second")
        print(f"   • Duration: {total_time:.1f} seconds")
        print(f"✨ Done! Check Datadog logs and your S3/Snowflake destination for forwarded logs.")


def main():
    parser = argparse.ArgumentParser(
        description='Generate logs directly to Datadog',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Quick test - user events
  python datadog_log_generator.py --dd-api-key YOUR_KEY --total-logs 50 --rate 5 --event-type user-events

  # System events test
  python datadog_log_generator.py --dd-api-key YOUR_KEY --total-logs 200 --rate 20 --event-type system-events

  # API events load test
  python datadog_log_generator.py --dd-api-key YOUR_KEY --total-logs 1000 --rate 50 --event-type api-events
        """
    )
    
    parser.add_argument('--dd-api-key', required=True, 
                       help='Your Datadog API key')
    parser.add_argument('--dd-site', default='datadoghq.com',
                       help='Datadog site (default: datadoghq.com)')
    parser.add_argument('--total-logs', type=int, default=100,
                       help='Total logs to generate (default: 100)')
    parser.add_argument('--rate', type=int, default=10,
                       help='Logs per second (default: 10)')
    parser.add_argument('--batch-size', type=int, default=100,
                       help='Logs per batch (default: 100)')
    parser.add_argument('--event-type', default='user-events',
                       choices=['user-events', 'system-events', 'api-events'],
                       help='Type of events to generate (default: user-events)')
    
    args = parser.parse_args()
    
    # Validate arguments
    if args.total_logs <= 0:
        print("❌ Total logs must be greater than 0")
        sys.exit(1)
    
    if args.rate <= 0:
        print("❌ Rate must be greater than 0")
        sys.exit(1)
    
    # Adjust batch size for efficiency
    if args.batch_size > args.rate * 10:  # Don't batch more than 10 seconds worth
        args.batch_size = max(1, args.rate * 5)  # Adjust to 5 seconds worth
        print(f"⚠️  Adjusted batch size to {args.batch_size} for better rate control")
    
    # Validate API key format (basic check)
    if len(args.dd_api_key) < 32:
        print("❌ API key appears to be invalid (too short)")
        sys.exit(1)
    
    generator = EnhancedDatadogLogGenerator(args.dd_api_key, args.dd_site)
    generator.run_generator(args.total_logs, args.rate, args.batch_size, args.event_type)


if __name__ == "__main__":
    main()