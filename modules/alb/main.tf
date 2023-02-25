
locals {
  vpc_name          = var.vpc_namespace
  app_port          = var.app_port
  private_subnets   = var.private_subnets
  public_subnets    = var.public_subnets
  health_check_path = var.health_check_path
  vpc_id            = var.vpc_id

  common_tags = {
    Environment = "demo"
    Project     = "${local.vpc_name}"
  }
}

# ALB Security Group: Edit to restrict access to the application
resource "aws_security_group" "this" {
  name        = "${local.vpc_name}-alb-sg"
  description = "controls access to the ALB"
  vpc_id      = local.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = local.app_port
    to_port     = local.app_port
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress { // all traffic out from alb available to all internet
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "${local.vpc_name}-load-balancer-sg"
    },
    local.common_tags
  )
}

resource "aws_alb" "this" {
  name            = "${local.vpc_name}-ALB"
  internal        = false
  subnets         = local.public_subnets
  security_groups = [aws_security_group.this.id]

  tags = {
    Name = "${local.vpc_name}-alb"
  }
}

// TARGET GROUP

resource "aws_alb_target_group" "this" {
  name                 = "${local.vpc_name}-TG"
  port                 = var.app_port
  protocol             = "HTTP"
  vpc_id               = local.vpc_id
  target_type          = "ip"
  deregistration_delay = "300"

  health_check {
    protocol            = "HTTP"
    path                = local.health_check_path
    matcher             = "200,301,302,305" 
    interval            = 60
    timeout             = 30
    healthy_threshold   = "3"
    unhealthy_threshold = "2"
  }

  tags = {
    "Name" = "${local.vpc_name}-TG"
  }
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "this" {
  load_balancer_arn = aws_alb.this.arn
  port              = local.app_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.this.arn

  }

  depends_on = [
    aws_alb_target_group.this
  ]
}
