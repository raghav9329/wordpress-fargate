
variable "create_lb" {
  description = "Controls if the Load Balancer should be created"
  type        = bool
  default     = true
}

variable "vpc_namespace" {
  description = "The project namespace to use for unique resource naming"
  default     = ""
  type        = string
}

variable "private_subnets" {
  type        = list(string)
  description = "list of private subnets"
}

variable "public_subnets" {
  type        = list(string)
  description = "list of public subnets"
}

variable "vpc_id" {
  description = "ID of the vpc"
}

variable "app_port" {}

variable "health_check_path" {
  type        = string
  description = "health check path"
}
