variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
  default     = "main-vpc"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for the first public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for the second public subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "public_subnet_3_cidr" {
  description = "CIDR block for the third public subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "private_subnet_1_cidr" {
  description = "CIDR block for the first private subnet"
  type        = string
  default     = "10.0.4.0/24"
}

variable "private_subnet_2_cidr" {
  description = "CIDR block for the second private subnet"
  type        = string
  default     = "10.0.5.0/24"
}

variable "private_subnet_3_cidr" {
  description = "CIDR block for the third private subnet"
  type        = string
  default     = "10.0.6.0/24"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_route_destination_cidr_block" {
  description = "Destination CIDR block for the public route table"
  type        = string
  default     = "0.0.0.0/0"
}

variable "environment" {
  description = "The environment for this VPC (dev, demo)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for the resources"
  type        = string
  default     = "dev-aws-project"
}
