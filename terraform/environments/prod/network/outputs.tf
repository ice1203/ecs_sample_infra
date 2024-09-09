output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "vpc id"
}
output "public_subnets" {
  value       = module.vpc.public_subnets
  description = "public subnets"
}
output "private_subnets_cidr_blocks" {
  value       = module.vpc.private_subnets_cidr_blocks
  description = "private_subnets_cidr_blocks"

}
