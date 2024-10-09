resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-1"
  }

  depends_on = [aws_vpc.main]
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-2"
  }

  depends_on = [aws_vpc.main]
}

resource "aws_subnet" "public_subnet_3" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_3_cidr
  availability_zone       = var.availability_zones[2]
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-3"
  }

  depends_on = [aws_vpc.main]
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = var.availability_zones[0]
  tags = {
    Name = "private-subnet-1"
  }

  depends_on = [aws_vpc.main]
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = var.availability_zones[1]
  tags = {
    Name = "private-subnet-2"
  }

  depends_on = [aws_vpc.main]
}

resource "aws_subnet" "private_subnet_3" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_3_cidr
  availability_zone = var.availability_zones[2]
  tags = {
    Name = "private-subnet-3"
  }

  depends_on = [aws_vpc.main]
}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-igw"
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
    Name = "public-route-table"
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
    Name = "private-route-table"
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
