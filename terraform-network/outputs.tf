#Network
output "vpc_id" {
  value = module.network.vpc_id
}

output "private_subnets" {
  value = module.network.private_subnets
}

output "public_subnets" {
  value = module.network.public_subnets
}

output "availability_zones" {
  value = module.network.availability_zones
}

output "vpc_security_group_id" {
  value = module.network.vpc_security_group_id
}

output "vpc_cidr_block" {
  value = module.network.vpc_cidr_block
}
