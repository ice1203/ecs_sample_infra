
# deploy
locals {
  sys_name = "sample"
  env_name = "prod"
  # ecspressoによるECSサービスデプロイ後にコメントアウトを外して実行
  # ecs_service_name = "sample-prod-frontend-svc"
}
data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = var.tfstate_bucket_name
    key    = "ecs-sample-infra/terraform/prod/network/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
module "service-ecr" {
  source = "../../../../modules/ecr"

  sys_name    = local.sys_name
  env_name    = local.env_name
  subsys_name = "frontend"

}
module "service-ecs" {
  source = "../../../../modules/ecs"

  sys_name                = local.sys_name
  env_name                = local.env_name
  subsys_name             = "frontend"
  vpc_id                  = data.terraform_remote_state.network.outputs.vpc_id
  public_subnets          = data.terraform_remote_state.network.outputs.public_subnets
  alb_listener_port       = 80
  docker_container_port   = 8080
  alb_allowed_cidr_blocks = data.terraform_remote_state.network.outputs.private_subnets_cidr_blocks
  allowed_cidr_blocks     = var.allowed_cidr_blocks

}
# module "codedeploy" {
#   source = "../../../../modules/codedeploy"

#   sys_name                = local.sys_name
#   env_name                = local.env_name
#   subsys_name             = "frontend"
#   ecs_cluster_name        = module.frontend-ecs.ecs_cluster_name
#   ecs_service_name        = local.ecs_service_name
#   prod_listener_arn       = module.frontend-ecs.prod_listener_arn
#   test_listener_arn       = module.frontend-ecs.test_listener_arn
#   blue_target_group_name  = module.frontend-ecs.blue_target_group_name
#   green_target_group_name = module.frontend-ecs.green_target_group_name

# }
# #ecspressoによるECSサービスデプロイ後にコメントアウトを外して実行
# module "application-autoscaling" {
#   source = "../../../../modules/application-autoscaling"

#   sys_name         = local.sys_name
#   env_name         = local.env_name
#   subsys_name      = "frontend"
#   ecs_cluster_name = module.frontend-ecs.ecs_cluster_name
#   ecs_service_name = local.ecs_service_name
#   min_capacity     = 0
#   max_capacity     = 0

# }
