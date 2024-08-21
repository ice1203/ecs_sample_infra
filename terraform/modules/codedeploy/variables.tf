variable "sys_name" {
  type        = string
  description = "system name"

}
variable "subsys_name" {
  type        = string
  description = "sub system name"

}
variable "env_name" {
  type        = string
  description = "environment name"

}
variable "ecs_cluster_name" {
  type        = string
  description = "ecs cluster name"

}
variable "ecs_service_name" {
  type        = string
  description = "ecs service name"

}

variable "prod_listener_arn" {
  type        = string
  description = "prod listener arn"
}
variable "test_listener_arn" {
  type        = string
  description = "test listener arn"
}
variable "blue_target_group_name" {
  type        = string
  description = "blue target group name"
}
variable "green_target_group_name" {
  type        = string
  description = "green target group name"
}
