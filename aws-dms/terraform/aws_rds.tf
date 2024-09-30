# Define the security group for the RDS instance
resource "aws_security_group" "rds_sg" {
  name        = "${local.resource_name_prefix}-rds-sg"
  description = "Allow RDS access within VPC"
  vpc_id      = module.data_vpc.vpc_id

  ingress {
    from_port   = 3306 # MySQL port; change to 5432 for PostgreSQL
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict access to your CIDR
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Define the subnet group for the RDS instance
resource "aws_db_subnet_group" "db_private_subnet_group" {
  name       = "${local.resource_name_prefix}-db-private-subnet-group"
  subnet_ids = module.data_vpc.private_subnet_id
}

# Define the subnet group for the RDS instance
resource "aws_db_subnet_group" "db_public_subnet_group" {
  name       = "${local.resource_name_prefix}-db-public-subnet-group"
  subnet_ids = module.data_vpc.public_subnet_id
}

# Define the parameter group for the RDS instance
resource "aws_db_parameter_group" "rds_pg" {
  name   = "${local.resource_name_prefix}-rds-mysql8-pg"
  family = "mysql8.0"

  # Set the sql_mode parameter
  parameter {
    name  = "sql_mode"
    value = "ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION,PAD_CHAR_TO_FULL_LENGTH"
  }

  # Other parameters
  parameter {
    name  = "binlog_format"
    value = "ROW"
  }

  parameter {
    name  = "binlog_row_image"
    value = "FULL"
  }

  parameter {
    name  = "binlog_row_metadata"
    value = "FULL"
  }
}

# Create the RDS instance
resource "aws_db_instance" "db_instance" {
  identifier              = "${local.resource_name_prefix}-demo-db"
  publicly_accessible     = true
  allocated_storage       = 20
  max_allocated_storage   = 100
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  username                = "admin"
  password                = aws_secretsmanager_secret_version.db_password_version.secret_string
  parameter_group_name    = aws_db_parameter_group.rds_pg.name #"default.mysql8.0"
  skip_final_snapshot     = true
  backup_retention_period = 7

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.db_public_subnet_group.name

}