# deploy
# locals {
#   sys_name = "sample"
#   env_name = "prod"
# }

# module "rds" {
#   source = "../../modules/ecs"

#   sys_name                = local.sys_name
#   env_name                = local.env_name
#   subsys_name             = "frontend"
#   vpc_id                  = module.vpc.vpc_id
#   public_subnets          = module.vpc.public_subnets
#   alb_listener_port       = 80
#   docker_container_port   = 8080
#   alb_allowed_cidr_blocks = module.vpc.private_subnets_cidr_blocks
#   allowed_cidr_blocks     = var.allowed_cidr_blocks

# }
