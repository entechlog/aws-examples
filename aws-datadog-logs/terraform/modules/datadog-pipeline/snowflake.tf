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

  # Table structure
  column {
    name = "_ID"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "LAMBDA_REQUEST_ID"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "EVENT_NAME"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "EVENT_DATE"
    type = "DATE"
  }

  column {
    name = "EVENT_TIMESTAMP"
    type = "TIMESTAMP_NTZ(9)"
  }

  column {
    name = "PROCESSED_TIMESTAMP"
    type = "TIMESTAMP_NTZ(9)"
  }

  column {
    name = "DATE"
    type = "TIMESTAMP_NTZ(9)"
  }

  column {
    name = "HOST"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "SERVICE"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "SOURCE"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "STATUS"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "MESSAGE"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "PIPELINE"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "ATTRIBUTES"
    type = "VARIANT"
  }

  column {
    name = "TAGS"
    type = "VARIANT"
  }

  cluster_by = ["EVENT_DATE", "EVENT_NAME"]

  comment = "Datadog logs for ${local.normalized_event_name} events"
}

resource "snowflake_grant_privileges_to_account_role" "table_grants" {
  count = var.destination_type == "snowflake" ? 1 : 0

  privileges        = ["SELECT", "INSERT", "UPDATE", "DELETE"]
  account_role_name = var.snowflake_role

  on_schema_object {
    object_type = "TABLE"
    object_name = "\"${var.snowflake_database}\".\"${var.snowflake_schema}\".\"${local.table_name}\""
  }

  depends_on = [snowflake_table.datadog_table]
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