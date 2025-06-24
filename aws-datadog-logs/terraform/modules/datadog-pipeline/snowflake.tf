# Add required providers to module
terraform {
  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "~> 2.1.0"
    }
  }
}

# Snowflake table configuration
variable "create_snowflake_table" {
  description = "Whether to automatically create the Snowflake table"
  type        = bool
  default     = true
}

variable "snowflake_table_comment" {
  description = "Comment for the Snowflake table"
  type        = string
  default     = ""
}

# Create Snowflake table automatically (only when destination is snowflake)
resource "snowflake_table" "datadog_table" {
  count = var.destination_type == "snowflake" ? 1 : 0

  database = var.snowflake_database
  schema   = var.snowflake_schema
  name     = local.table_name

  # Table structure for Datadog logs - ALL UPPERCASE (Snowflake standard)
  column {
    name    = "ID"
    type    = "VARCHAR"
    comment = "Unique identifier for the log entry"
  }

  column {
    name    = "LAMBDA_REQUEST_ID"
    type    = "VARCHAR"
    comment = "AWS Lambda request ID"
  }

  column {
    name    = "EVENT_NAME"
    type    = "VARCHAR"
    comment = "Event type name"
  }

  column {
    name    = "EVENT_DATE"
    type    = "DATE"
    comment = "Date of the event"
  }

  column {
    name    = "EVENT_TIMESTAMP"
    type    = "TIMESTAMP_NTZ"
    comment = "Original event timestamp"
  }

  column {
    name    = "PROCESSED_TIMESTAMP"
    type    = "TIMESTAMP_NTZ"
    comment = "Lambda processing timestamp"
  }

  # Datadog core fields
  column {
    name    = "DATE"
    type    = "TIMESTAMP_NTZ"
    comment = "Datadog log date"
  }

  column {
    name    = "HOST"
    type    = "VARCHAR"
    comment = "Source host"
  }

  column {
    name    = "SERVICE"
    type    = "VARCHAR"
    comment = "Service name"
  }

  column {
    name    = "SOURCE"
    type    = "VARCHAR"
    comment = "Log source"
  }

  column {
    name    = "STATUS"
    type    = "VARCHAR"
    comment = "Log status/level"
  }

  column {
    name    = "MESSAGE"
    type    = "TEXT"
    comment = "Log message content"
  }

  # Pipeline metadata
  column {
    name    = "PIPELINE"
    type    = "VARCHAR"
    comment = "Processing pipeline identifier"
  }

  column {
    name    = "DESTINATION_TYPE"
    type    = "VARCHAR"
    comment = "Destination type (s3/snowflake)"
  }

  column {
    name    = "TABLE_NAME"
    type    = "VARCHAR"
    comment = "Target table name"
  }

  column {
    name    = "BATCH_ID"
    type    = "VARCHAR"
    comment = "Processing batch identifier"
  }

  # Nested data as JSON/VARIANT
  column {
    name    = "ATTRIBUTES"
    type    = "VARIANT"
    comment = "Datadog log attributes (JSON)"
  }

  column {
    name    = "TAGS"
    type    = "VARIANT"
    comment = "Datadog log tags (JSON)"
  }

  # Clustering for better performance - NOW MATCHES COLUMN NAMES
  cluster_by = ["EVENT_DATE", "EVENT_NAME"]

  comment = "Datadog logs for ${local.normalized_event_name} events"
}

# Snowflake table outputs
output "snowflake_table_name" {
  description = "Created Snowflake table name"
  value       = var.destination_type == "snowflake" ? snowflake_table.datadog_table[0].name : null
}

output "snowflake_table_fully_qualified_name" {
  description = "Fully qualified Snowflake table name"
  value       = var.destination_type == "snowflake" ? "${var.snowflake_database}.${var.snowflake_schema}.${local.table_name}" : null
}