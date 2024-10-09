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
