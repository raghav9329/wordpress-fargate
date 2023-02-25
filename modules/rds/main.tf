
locals {
  app_name             = "${var.vpc_namespace}-rds"
  vpc_id               = var.vpc_id
  rds_port             = var.rds_port
  rds_cidr_blocks      = [var.vpc_cidr]
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = var.db_password
  db_subnet_group_name = var.db_subnet_group_name
  private_subnets      = var.private_subnets
  region               = var.region
  instance_class       = var.instance_class # if none provided the default one is "db.t2.micro" ( REQUIRED)

  common_tags = {
    Environment = "demo"
    Project     = "${local.app_name}"
  }
}

# Create RDS Security Group and ingress and egress rules
# https://www.terraform.io/docs/providers/aws/r/security_group.html

resource "aws_security_group" "this" {
  name   = "${local.app_name}-SG"
  vpc_id = local.vpc_id

  tags = {
    Name = "${local.app_name}-SG"
  }
}

resource "aws_security_group_rule" "ingress" {
  type              = "ingress"
  from_port         = local.rds_port
  to_port           = local.rds_port
  protocol          = "TCP"
  cidr_blocks       = local.rds_cidr_blocks
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}

resource "aws_db_subnet_group" "this" {
  name        = local.db_subnet_group_name
  subnet_ids  = local.private_subnets
  description = "database subnet group for wordpress fargate rds cluster"

  tags = {
    Name = "${local.app_name}-db-SubnetGroup"
  }
}

resource "aws_db_instance" "this" {
  identifier           = "${local.app_name}-db" # the DB cluster identifier 
  storage_type         = "gp3"                 
  allocated_storage    = 20                    
  engine               = "mysql"
  engine_version       = "8.0"                 
  instance_class       = local.instance_class
  port                 = local.rds_port      
  db_subnet_group_name = aws_db_subnet_group.this.name
  db_name              = local.db_name 
  username = local.db_username
  password = local.db_password
  parameter_group_name   = "default.mysql8.0" 
  availability_zone      = "${local.region}a" 
  publicly_accessible    = false             
  deletion_protection    = false              
  skip_final_snapshot    = true             
  vpc_security_group_ids = [aws_security_group.this.id]

  tags = {
    Name = "${local.app_name}-DB"
  }
}
