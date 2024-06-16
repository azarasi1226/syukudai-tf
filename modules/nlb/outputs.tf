output "alb_arn" {
  value = aws_lb.this.arn
}

output "prod_listener_arn" {
  value = aws_lb_listener.prod.arn
}

output "test_listener_arn" {
  value = aws_lb_listener.test.arn
}

output "blue_targetgroup_arn" {
  value = aws_lb_target_group.blue.arn
}

output "blue_targetgroup_name" {
  value = aws_lb_target_group.blue.name
}

output "green_targetgroup_arn" {
  value = aws_lb_target_group.green.arn
}

output "green_targetgroup_name" {
  value = aws_lb_target_group.green.name
}