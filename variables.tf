variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for the first public subnet"
  type        = string
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for the second public subnet"
  type        = string
}

variable "public_subnet_3_cidr" {
  description = "CIDR block for the third public subnet"
  type        = string
}

variable "private_subnet_1_cidr" {
  description = "CIDR block for the first private subnet"
  type        = string
}

variable "private_subnet_2_cidr" {
  description = "CIDR block for the second private subnet"
  type        = string
}

variable "private_subnet_3_cidr" {
  description = "CIDR block for the third private subnet"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "public_route_destination_cidr_block" {
  description = "Destination CIDR block for the public route table"
  type        = string
}

variable "environment" {
  description = "The environment for this VPC (dev, demo)"
  type        = string
}

variable "project_name" {
  description = "Project name for the resources"
  type        = string
}

# AWS EC2
variable "ami_id" {
  description = "AMI ID"
  type        = string
}

variable "instance_type" {
  description = "Type of EC2 instance"
  type        = string
}

variable "key_name" {
  description = "Name of key pair for EC2"
  type        = string
}

variable "volume_size" {
  description = "Instance volume size"
  type        = number
}

variable "volume_type" {
  description = "Instance volume type"
  type        = string
}

variable "instance_name" {
  description = "Name of EC2 instance"
  type        = string
}

variable "security_group_name" {
  description = "Name of security group"
  type        = string
}

variable "service_ports" {
  description = "Inbound ports"
  type        = list(string)
}

variable "protocol" {
  description = "TCP protocol declaration"
  type        = string
}

variable "ipv4_cidr_blocks" {
  description = "IPv4 CIDR"
  type        = list(string)
}

variable "ipv6_cidr_blocks" {
  description = "IPv6 CIDR"
  type        = list(string)
}
