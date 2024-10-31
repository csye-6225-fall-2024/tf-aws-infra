resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project_name}-${var.environment}-vpc"
  }
}

# Public Subnets
resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index % length(var.availability_zones)]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-${var.environment}-public-subnet-${count.index + 1}"
  }

  depends_on = [aws_vpc.main]
}

# Private Subnets
resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index % length(var.availability_zones)]

  tags = {
    Name = "${var.project_name}-${var.environment}-private-subnet-${count.index + 1}"
  }

  depends_on = [aws_vpc.main]
}

# Internet Gateway
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-${var.environment}-igw"
  }

  depends_on = [aws_vpc.main]
}

# Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.public_route_destination_cidr_block
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-public-route-table"
  }

  depends_on = [aws_vpc.main]
}

# Private Route Table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-${var.environment}-private-route-table"
  }

  depends_on = [aws_vpc.main]
}

# Public Route Table Association
resource "aws_route_table_association" "public_subnet_routes" {
  count          = length(aws_subnet.public_subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id

  depends_on = [aws_vpc.main]
}

# Private Route Table Association
resource "aws_route_table_association" "private_subnet_routes" {
  count          = length(aws_subnet.private_subnets)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_table.id

  depends_on = [aws_vpc.main]
}

locals {
  app_port = var.service_ports[3]
}

# AWS EC2
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  subnet_id              = aws_subnet.public_subnets[0].id
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  iam_instance_profile = aws_iam_instance_profile.cloudwatch_profile.name

  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo "DB_HOST=${aws_db_instance.csye6225.address}" >> /etc/webapp.env
              echo "DB_NAME=${aws_db_instance.csye6225.db_name}" >> /etc/webapp.env
              echo "DB_USER=${aws_db_instance.csye6225.username}" >> /etc/webapp.env
              echo "DB_PASSWORD=${aws_db_instance.csye6225.password}" >> /etc/webapp.env
              echo "DB_PORT=${aws_db_instance.csye6225.port}" >> /etc/webapp.env
              echo "PORT=${var.service_ports[3]}" >> /etc/webapp.env
              echo "S3_BUCKET_NAME=${aws_s3_bucket.webapp_bucket.id}" >> /etc/webapp.env
              chmod 600 /etc/webapp.env
              chown root:root /etc/webapp.env

              sudo systemctl daemon-reload

              sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
              -a fetch-config \
              -m ec2 \
              -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
              -s

              systemctl enable amazon-cloudwatch-agent
              systemctl start amazon-cloudwatch-agent

              sudo systemctl enable webapp
              sudo systemctl start webapp
              EOF
  )

  tags = {
    Name = var.instance_name
  }
}

# AWS EC2 Security Group Settings
resource "aws_security_group" "app_sg" {
  vpc_id      = aws_vpc.main.id
  name        = "${var.project_name}-${var.environment}-app-sg"
  description = "Security group for web app"

  dynamic "ingress" {
    for_each = var.service_ports
    content {
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = var.protocol
      cidr_blocks      = var.ipv4_cidr_blocks
      ipv6_cidr_blocks = var.ipv6_cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS Instance
resource "aws_db_instance" "csye6225" {
  identifier             = var.db_identifier
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage
  db_name                = var.db_name
  username               = var.db_user
  password               = var.db_password
  port                   = var.db_port
  db_subnet_group_name   = aws_db_subnet_group.private_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  parameter_group_name   = aws_db_parameter_group.db_pg.name
  publicly_accessible    = false
  skip_final_snapshot    = true
  multi_az               = false

  tags = {
    Name = "${var.project_name}-${var.environment}-rds"
  }
}

# RDS Security Group
resource "aws_security_group" "db_sg" {
  name        = "${var.project_name}-${var.environment}-db-sg"
  description = "Security group for RDS instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = var.protocol
    security_groups = [aws_security_group.app_sg.id]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-db-sg"
  }
}

# RDS Subnet Group
resource "aws_db_subnet_group" "private_subnet_group" {
  name        = "${var.project_name}-${var.environment}-private-subnet-group"
  description = "Private subnet group for RDS instances"
  subnet_ids  = aws_subnet.private_subnets[*].id

  tags = {
    Name = "${var.project_name}-${var.environment}-private-subnet-group"
  }
}

# RDS Parameter Group
resource "aws_db_parameter_group" "db_pg" {
  family      = "mysql8.0"
  name        = "${var.project_name}-${var.environment}-pg"
  description = "Parameter group for RDS instances"

  parameter {
    name  = "max_connections"
    value = "100"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "collation_server"
    value = "utf8mb4_unicode_ci"
  }
}

# IAM Role for CloudWatch Agent
resource "aws_iam_role" "cloudwatch_agent_role" {
  name = "${var.project_name}-${var.environment}-cloudwatch-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Principal = { Service = "ec2.amazonaws.com" },
        Effect    = "Allow"
      }
    ]
  })
}

# CloudWatch IAM Policy Update
resource "aws_iam_policy" "cloudwatch_agent_policy" {
  name        = "${var.project_name}-${var.environment}-cloudwatch-policy"
  description = "Policy for CloudWatch agent with access to logs, metrics, S3, and RDS"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "cloudwatch:PutMetricData",
          "cloudwatch:GetMetricData",
          "cloudwatch:PutDashboard"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        Resource = [
          aws_s3_bucket.webapp_bucket.arn,
          "${aws_s3_bucket.webapp_bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "rds:DescribeDBInstances",
          "rds:Connect"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "attach_cloudwatch_policy" {
  role       = aws_iam_role.cloudwatch_agent_role.name
  policy_arn = aws_iam_policy.cloudwatch_agent_policy.arn
}

# IAM Instance Profile for CloudWatch Agent Role
resource "aws_iam_instance_profile" "cloudwatch_profile" {
  name = "${var.project_name}-${var.environment}-cloudwatch-instance-profile"
  role = aws_iam_role.cloudwatch_agent_role.name
}

# Generate a UUID for the S3 bucket name
resource "random_uuid" "s3_bucket_name" {}

# S3 Bucket for Attachments
resource "aws_s3_bucket" "webapp_bucket" {
  bucket        = random_uuid.s3_bucket_name.result
  force_destroy = true

  tags = {
    Name = "${var.project_name}-${var.environment}-attachments-bucket"
  }
}

# S3 Bucket Server-Side Encryption Configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "webapp_bucket_encryption" {
  bucket = aws_s3_bucket.webapp_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket Lifecycle Configuration
resource "aws_s3_bucket_lifecycle_configuration" "webapp_bucket_lifecycle" {
  bucket = aws_s3_bucket.webapp_bucket.bucket

  rule {
    id     = "transition-to-standard-ia"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}

# Route 53 Zone for Domain
resource "aws_route53_record" "webapp_a_record" {
  zone_id = var.hosted_zone_id
  name    = var.domain_name
  type    = var.record_type
  ttl     = var.record_ttl
  records = [aws_instance.web.public_ip]
}
