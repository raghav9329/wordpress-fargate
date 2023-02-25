#
# Terraform Provider(s) Variables
#

variable "account_id" {
  description = "The 12-digit account ID used for role assumption"
  /* default     = "1231431213" */
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "profile" {
  type    = string
  default = "default"
}


# VPC VARIABLES

variable "vpc_namespace" {
  description = "vpc for wordpress"
  default = "wordpress"
  type    = string
}

variable "prefix" {
  default     = "wp"
  description = "Common prefix for AWS resources names"
}

variable "vpc_cidr" {
  description = "AWS VPC CIDR range"
  type        = string
  default     = "10.20.0.0/16"
}

variable "private_subnets" {
  description = "The list of private subnets by AZ"
  type        = list(string)
  default     = ["10.20.4.0/24", "10.20.5.0/24"]
}

variable "public_subnets" {
  description = "The list of public subnets by AZ"
  type        = list(string)
  default     = ["10.20.0.0/24", "10.20.1.0/24"]
}

variable "enable_nat" {
  description = "To deploy or not to deploy a NAT Gateway"
  default     = "true"
}

# APPLICATION LOAD BALANCER VARIABLES

variable "app_port" {
  type        = number
  description = "app port for the alb"
  default     = 80
}

// variable for wordpress


variable "health_check_path" {
  default = "/" 
}


##              RDS VARIABLES                 ##

variable "instance_class" {
  type        = string
  description = "Instance type of the RDS instance"
  default     = "t2.micro"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "wordpress"
}

variable "db_password" {
  description = "DataBase Password"
  type        = string
  default     = "12345678"
}

variable "db_username" {
  description = "DataBase user name"
  type        = string
  default     = "admin"
}

variable "rds_port" {
  description = "DataBase security group port"
  default     = 3306
}

variable "db_subnet_group_name" {
  type        = string
  description = "describe your variable"
  default     = "wordpress_db_subnet_group"
}

# ECS FARGATE VARIABLES


variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = "2"
}

variable "app_count" {
  type        = number
  description = "total numbers of containers to be deployed"
  default     = 2
}

variable "app_name" {
  description = "Docker image to run in the ECS cluster"
  default = "wordpress"
}

variable "app_image" {
  description = "Docker image to run in the ECS cluster"
  default = "wordpress"
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "1024"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "2048"
}

// EFS VARS

variable "volume_name" {
  type        = string
  description = "efs volume name"
  default     = "efs_volume"
}

