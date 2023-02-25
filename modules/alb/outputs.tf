
output "alb_id" {
  value = aws_alb.this.id
}

output "alb_security_group_id" {
  value = aws_security_group.this.id
}

output "alb_target_group_id" {
  value = aws_alb_target_group.this.id
}

output "alb_target_group_arn" {
  value = aws_alb_target_group.this.arn
}

output "alb_listener_arn" {
  value = aws_alb_listener.this.arn
}
