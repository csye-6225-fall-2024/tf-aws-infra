resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project_name}-${var.environment}-vpc"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-${var.environment}-public-subnet-1"
  }

  depends_on = [aws_vpc.main]
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-${var.environment}-public-subnet-2"
  }

  depends_on = [aws_vpc.main]
}

resource "aws_subnet" "public_subnet_3" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_3_cidr
  availability_zone       = var.availability_zones[2]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-${var.environment}-public-subnet-3"
  }

  depends_on = [aws_vpc.main]
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = var.availability_zones[0]
  tags = {
    Name = "${var.project_name}-${var.environment}-private-subnet-1"
  }

  depends_on = [aws_vpc.main]
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = var.availability_zones[1]
  tags = {
    Name = "${var.project_name}-${var.environment}-private-subnet-2"
  }

  depends_on = [aws_vpc.main]
}

resource "aws_subnet" "private_subnet_3" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_3_cidr
  availability_zone = var.availability_zones[2]
  tags = {
    Name = "${var.project_name}-${var.environment}-private-subnet-3"
  }

  depends_on = [aws_vpc.main]
}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-${var.environment}-igw"
  }

  depends_on = [aws_vpc.main]
}

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

resource "aws_route_table_association" "public_route_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id

  depends_on = [aws_vpc.main]
}

resource "aws_route_table_association" "public_route_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id

  depends_on = [aws_vpc.main]
}

resource "aws_route_table_association" "public_route_assoc_3" {
  subnet_id      = aws_subnet.public_subnet_3.id
  route_table_id = aws_route_table.public_route_table.id

  depends_on = [aws_vpc.main]
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-${var.environment}-private-route-table"
  }

  depends_on = [aws_vpc.main]
}

resource "aws_route_table_association" "private_route_assoc_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id

  depends_on = [aws_vpc.main]
}

resource "aws_route_table_association" "private_route_assoc_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id

  depends_on = [aws_vpc.main]
}

resource "aws_route_table_association" "private_route_assoc_3" {
  subnet_id      = aws_subnet.private_subnet_3.id
  route_table_id = aws_route_table.private_route_table.id

  depends_on = [aws_vpc.main]
}

# AWS EC2
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  subnet_id              = aws_subnet.public_subnet_1.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]

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
              echo "PORT=${aws_db_instance.csye6225.port}" >> /etc/webapp.env
              chmod 600 /etc/webapp.env
              chown root:root /etc/webapp.env
              sudo systemctl daemon-reload
              sudo systemctl enable webapp
              sudo systemctl start webapp

              sudo systemctl status webapp
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

# Database Security Group
resource "aws_security_group" "db_sg" {
  name        = "${var.project_name}-${var.environment}-db-sg"
  description = "Security group for RDS instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = var.protocol
    security_groups = [aws_security_group.app_sg.id]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-db-sg"
  }
}

# RDS Parameter Group
resource "aws_db_parameter_group" "db_pg" {
  family = "mysql8.0"
  name   = "${var.project_name}-${var.environment}-pg"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "collation_server"
    value = "utf8mb4_unicode_ci"
  }
}

# RDS Subnet Group
resource "aws_db_subnet_group" "private_subnet_group" {
  name       = "${var.project_name}-${var.environment}-private-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id, aws_subnet.private_subnet_3.id]

  tags = {
    Name = "${var.project_name}-${var.environment}-private-subnet-group"
  }
}

# RDS Instance
resource "aws_db_instance" "csye6225" {
  identifier             = "csye6225"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = var.db_name
  username               = var.db_user
  password               = var.db_password
  port                   = var.port
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