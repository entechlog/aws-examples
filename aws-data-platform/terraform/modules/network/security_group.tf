resource "aws_security_group" "kafka_sg" {
  name        = "${lower(var.env_code)}-${lower(var.project_code)}-kafka-sg"
  description = "Security group for ${var.project_code} Kafka in ${upper(var.env_code)}"
  vpc_id      = aws_vpc.vpc.id

  tags = merge(local.tags, {
    Name = "${lower(var.env_code)}-${lower(var.project_code)}-kafka-sg"
  })
}

resource "aws_security_group_rule" "ingress_all" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.kafka_sg.id
}

resource "aws_security_group_rule" "open_monitoring_jmx" {
  count             = var.open_monitoring ? 1 : 0
  type              = "ingress"
  from_port         = 11001
  to_port           = 11001
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "prometheus jmx exporter"
  security_group_id = aws_security_group.kafka_sg.id
}

resource "aws_security_group_rule" "open_monitoring_node" {
  count             = var.open_monitoring ? 1 : 0
  type              = "ingress"
  from_port         = 11002
  to_port           = 11002
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "prometheus node exporter"
  security_group_id = aws_security_group.kafka_sg.id
}

resource "aws_security_group_rule" "kafka_default" {
  type              = "ingress"
  from_port         = 9092
  to_port           = 9092
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "kafka default"
  security_group_id = aws_security_group.kafka_sg.id
}

resource "aws_security_group_rule" "kafka_tls" {
  type              = "ingress"
  from_port         = 9094
  to_port           = 9094
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "kafka tls"
  security_group_id = aws_security_group.kafka_sg.id
}

resource "aws_security_group_rule" "kafka_sasl_scram" {
  type              = "ingress"
  from_port         = 9096
  to_port           = 9096
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "kafka scram"
  security_group_id = aws_security_group.kafka_sg.id
}

resource "aws_security_group_rule" "kafka_sasl_iam" {
  type              = "ingress"
  from_port         = 9098
  to_port           = 9098
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "kafka iam"
  security_group_id = aws_security_group.kafka_sg.id
}

resource "aws_security_group_rule" "zookeeper" {
  type              = "ingress"
  from_port         = 2081
  to_port           = 2081
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "zookeeper"
  security_group_id = aws_security_group.kafka_sg.id
}

resource "aws_security_group_rule" "zookeeper_tls" {
  type              = "ingress"
  from_port         = 2082
  to_port           = 2082
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "zookeeper tls"
  security_group_id = aws_security_group.kafka_sg.id
}

resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  to_port           = 0
  from_port         = 0
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.kafka_sg.id
}

resource "aws_security_group" "ssh_sg" {
  name        = "${lower(var.env_code)}-${lower(var.project_code)}-ssh-sg"
  description = "Security group for ${var.project_code} SSH in ${upper(var.env_code)}"
  vpc_id      = aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.remote_cidr_block, var.vpc_cidr_block]
  }
  tags = merge(local.tags, {
    Name = "${lower(var.env_code)}-${lower(var.project_code)}-ssh-sg"
  })
}