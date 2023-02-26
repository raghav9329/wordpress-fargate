# ECS MODULE VARIABLES

variable "region" {}

variable "vpc_id" {}

variable "app_image" {}

variable "app_port" {}

variable "fargate_cpu" {}

variable "fargate_memory" {
  type        = string
  description = "fargate memory"
}

variable "private_subnets" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}


variable "alb_security_group_id" {
  type        = list(string)
  description = "security groups allow in ecs cluster" // alb security group
}

variable "app_name" {
  type        = string
  description = " describe your variable"
}

variable "az_count" {}


variable "alb_target_group_arn" {}

variable "app_count" {
  type        = number
  description = "total of containers to be deployed"
}

variable "task_definition_name" {
  type    = string
  default = "wordpress-fargate"
}

# CLOUDWATCH VARIABLES

variable "awslogs-group-path" {
  type    = string
  default = "/ecs/wordpress-fargate"
}


// RDS VARIABLES

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_password" {
  description = "DataBase Password"
  type        = string
}

variable "db_username" {
  description = "DataBase user name"
  type        = string
}

variable "rds_endpoint" {}

// EFS VARIABLES

variable "efs_id" {
  type        = string
  description = "efs volume id "
}

variable "efs_access_point" {
  description = "access points of the efs volume"
}

variable "volume_name" {}
