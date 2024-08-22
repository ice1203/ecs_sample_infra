# deploy
locals {
  sys_name = "sample"
  env_name = "prod"
  # ecspressoによるECSサービスデプロイ後にコメントアウトを外して実行
  ecs_service_name = "sample-prod-frontend-svc"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = "${local.sys_name}-${local.env_name}-vpc"
  cidr = "172.18.0.0/16"

  azs             = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
  private_subnets = ["172.18.0.0/24", "172.18.1.0/24", "172.18.2.0/24"]
  public_subnets  = ["172.18.128.0/24", "172.18.129.0/24", "172.18.130.0/24"]

  enable_nat_gateway                   = true
  single_nat_gateway                   = true
  enable_vpn_gateway                   = false
  enable_dns_hostnames                 = true
  manage_default_network_acl           = true
  enable_flow_log                      = false
  flow_log_max_aggregation_interval    = 60
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true
  public_dedicated_network_acl         = true

  tags = {
    Environment = local.env_name
  }
}

module "frontend-ecr" {
  source = "../../modules/ecr"

  sys_name    = local.sys_name
  env_name    = local.env_name
  subsys_name = "frontend"

}
module "frontend-ecs" {
  source = "../../modules/ecs"

  sys_name                = local.sys_name
  env_name                = local.env_name
  subsys_name             = "frontend"
  vpc_id                  = module.vpc.vpc_id
  public_subnets          = module.vpc.public_subnets
  alb_listener_port       = 80
  docker_container_port   = 8080
  alb_allowed_cidr_blocks = module.vpc.private_subnets_cidr_blocks
  allowed_cidr_blocks     = var.allowed_cidr_blocks

}
module "codedeploy" {
  source = "../../modules/codedeploy"

  sys_name                = local.sys_name
  env_name                = local.env_name
  subsys_name             = "frontend"
  ecs_cluster_name        = module.frontend-ecs.ecs_cluster_name
  ecs_service_name        = local.ecs_service_name
  prod_listener_arn       = module.frontend-ecs.prod_listener_arn
  test_listener_arn       = module.frontend-ecs.test_listener_arn
  blue_target_group_name  = module.frontend-ecs.blue_target_group_name
  green_target_group_name = module.frontend-ecs.green_target_group_name

}
#ecspressoによるECSサービスデプロイ後にコメントアウトを外して実行
module "application-autoscaling" {
  source = "../../modules/application-autoscaling"

  sys_name         = local.sys_name
  env_name         = local.env_name
  subsys_name      = "frontend"
  ecs_cluster_name = module.frontend-ecs.ecs_cluster_name
  ecs_service_name = local.ecs_service_name
  min_capacity     = 1
  max_capacity     = 1

}
