output "ecs_cluster_name" {
  value       = aws_ecs_cluster.my_cluster.name
  description = "ecs cluster name"
}
output "prod_listener_arn" {
  value       = aws_lb_listener.my_alb_prod.arn
  description = "prod listener arn"
}
output "test_listener_arn" {
  value       = aws_lb_listener.my_alb_test.arn
  description = "test listener arn"
}
output "blue_target_group_name" {
  value       = aws_lb_target_group.my_alb_1.name
  description = "blue target group name"
}
output "green_target_group_name" {
  value       = aws_lb_target_group.my_alb_2.name
  description = "green target group name"
}
