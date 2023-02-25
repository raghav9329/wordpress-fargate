
locals {
  region                = var.region
  vpc_id                = var.vpc_id
  app_name              = var.app_name
  task_definition_name  = var.task_definition_name
  app_image             = var.app_image
  app_port              = var.app_port
  fargate_memory        = var.fargate_memory
  fargate_cpu           = var.fargate_cpu
  private_subnets       = var.private_subnets
  alb_security_group_id = var.alb_security_group_id
  app_count             = var.app_count
  alb_target_group_arn  = var.alb_target_group_arn
  efs_id                = var.efs_id
  efs_access_point_id   = var.efs_access_point
  volume_name           = var.volume_name


  common_tags = {
    Environment = "demo"
    Project     = "${local.app_name}"
  }
}

# TEMPLATE TO BE USED IN THE TASK DEFINITION
data "template_file" "ecs_task_definition" {
  template = file("./modules/fargate/task-definitions/myapp.json.tpl")

  vars = {
    task_definition_name                   = var.task_definition_name 
    app_image                              = var.app_image            
    app_port                               = var.app_port            
    fargate_cpu                            = var.fargate_cpu
    fargate_memory                         = var.fargate_memory
    region                                 = var.region
    log_group_path                         = var.awslogs-group-path
    rds_endpoint                           = var.rds_endpoint
    db_name                                = var.db_name
    db_username                            = var.db_username
    db_password                            = var.db_password
    container_file_system_local_mount_path = "/mnt/efs"
    volume_name                            = var.volume_name

  }
}

# Set up CloudWatch group and log stream and retain logs for 30 days

resource "aws_ecs_cluster" "this" {
  name = "${local.app_name}-cluster"
}

resource "aws_ecs_task_definition" "app-task-definition" {
  family                   = local.app_name
  execution_role_arn       = aws_iam_role.ecs_cluster_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.ecs_task_definition.rendered
  // EFS VOLUME CONFIG
  volume {
    name = local.volume_name
    efs_volume_configuration {
      file_system_id = local.efs_id
      root_directory     = "/"
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = local.efs_access_point_id
        iam             = "DISABLED"
      }
    }
  }

  tags = merge(
    {
      Name = "${local.app_name}-TaskDefinition"
    },
    local.common_tags
  )
}

# Traffic to the ECS cluster should only come from the ALB
resource "aws_security_group" "app-security-group" {
  name        = "${local.app_name}-ECS-SG"
  description = "application SG to allow inbound access from the ALB only"
  vpc_id      = local.vpc_id

  ingress {
    protocol        = "TCP"
    from_port       = var.app_port
    to_port         = var.app_port
    security_groups = local.alb_security_group_id
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "${local.app_name}-SG"
    },
    local.common_tags
  )
}

resource "aws_ecs_service" "ecs_service" {
  name            = "${local.app_name}-ecs-service"
  task_definition = aws_ecs_task_definition.app-task-definition.arn
  desired_count   = local.app_count
  launch_type     = "FARGATE"
  cluster         = aws_ecs_cluster.this.id

  network_configuration {
    security_groups  = [aws_security_group.app-security-group.id]
    subnets          = local.private_subnets
    assign_public_ip = true
  }

  load_balancer {
    container_name   = local.task_definition_name // nginx-fargate, it has to match the name inside of the myapp.json.tpl "name": "task_definition_name"
    target_group_arn = local.alb_target_group_arn
    container_port   = local.app_port
  }

}


