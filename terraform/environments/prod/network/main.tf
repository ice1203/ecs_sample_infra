# deploy
locals {
  sys_name = "sample"
  env_name = "prod"
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
