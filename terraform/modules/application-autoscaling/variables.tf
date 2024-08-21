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
variable "min_capacity" {
  type        = string
  description = "ecs task min capacity"

}
variable "max_capacity" {
  type        = string
  description = "ecs task max capacity"

}
