locals {
  awslogs_group_path = var.awslogs-group-path
}


resource "aws_cloudwatch_log_group" "this" {
  name              = local.awslogs_group_path
  retention_in_days = 30

  tags = {
    Name = "${local.app_name}-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "this" {
  name           = "my-log-stream"
  log_group_name = aws_cloudwatch_log_group.this.name
}
