module "s3" {
  source  = "../terraform-modules/s3"
  tags    = local.tags
  buckets = local.buckets

  depends_on = [
    data.terraform_remote_state.network
  ]
}

module "compute" {
  source          = "../terraform-modules/compute"
  tags            = local.tags
  ecs_services    = var.ecs_services
  vpc_id          = data.terraform_remote_state.network.outputs.vpc_id
  public_subnets  = data.terraform_remote_state.network.outputs.public_subnets
  hosted_zone_id  = data.terraform_remote_state.global_resources.outputs.hosted_zone_id
  acm_certificate = data.terraform_remote_state.global_resources.outputs.acm_certificate

  depends_on = [
    data.terraform_remote_state.network
  ]
}

module "container" {
  source                    = "../terraform-modules/container"
  tags                      = local.tags
  ecs_services              = var.ecs_services
  alb_sg                    = module.compute.alb_sg
  jetolink_ecr_repos        = local.jetolink_ecr_repos
  aws_iam_policy_settings   = local.aws_iam_policy_settings
  target_group_arns         = module.compute.target_group_arns
  vpc_id                    = data.terraform_remote_state.network.outputs.vpc_id
  private_subnets           = data.terraform_remote_state.network.outputs.private_subnets
  default_security_group_id = [data.terraform_remote_state.network.outputs.vpc_security_group_id]

  providers = {
    aws.mgmt = aws.mgmt
  }

  depends_on = [
    module.compute,
    data.terraform_remote_state.network
  ]
}

module "redis" {
  source                     = "../terraform-modules/elasticache-redis"
  tags                       = local.tags
  family                     = var.family
  redis_port                 = var.redis_port
  redis_engine               = var.redis_engine
  cluster_size               = var.cluster_size
  num_node_groups            = var.num_node_groups
  multi_az_enabled           = var.multi_az_enabled
  redis_instance_type        = var.redis_instance_type
  engine_version             = var.redis_engine_version
  replicas_per_node_group    = var.replicas_per_node_group
  transit_encryption_enabled = var.transit_encryption_enabled
  automatic_failover_enabled = var.automatic_failover_enabled
  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  vpc_id                     = data.terraform_remote_state.network.outputs.vpc_id
  private_subnets            = data.terraform_remote_state.network.outputs.private_subnets
  availability_zones         = data.terraform_remote_state.network.outputs.availability_zones
  default_security_group_id  = [data.terraform_remote_state.network.outputs.vpc_security_group_id]

  depends_on = [
    data.terraform_remote_state.network
  ]
}

module "postgres" {
  source                    = "../terraform-modules/aurora-postgress"
  engine                    = var.engine
  tags                      = local.tags
  engine_version            = var.engine_version
  rds_instance_class        = var.rds_instance_class
  skip_final_snapshot       = var.skip_final_snapshot
  deletion_protection       = var.deletion_protection
  backup_retention_period   = var.backup_retention_period
  preferred_backup_window   = var.preferred_backup_window
  vpc_id                    = data.terraform_remote_state.network.outputs.vpc_id
  vpc_cidr_block            = data.terraform_remote_state.network.outputs.vpc_cidr_block
  public_subnets            = data.terraform_remote_state.network.outputs.public_subnets
  private_subnets           = data.terraform_remote_state.network.outputs.private_subnets
  default_security_group_id = [data.terraform_remote_state.network.outputs.vpc_security_group_id]
  aurora_master_username    = data.terraform_remote_state.global_resources.outputs.db_secret_username
  aurora_master_password    = data.terraform_remote_state.global_resources.outputs.db_secret_password

  providers = {
    aws.mgmt = aws.mgmt
  }

  depends_on = [
    data.terraform_remote_state.network
  ]
}

module "msk-kafka" {
  source                    = "../terraform-modules/msk-kafka"
  tags                      = local.tags
  broker_count              = var.broker_count
  kafka_version             = var.kafka_version
  kafka_instance_type       = var.kafka_instance_type
  ecs_security_group_id     = module.container.ecs_sg_id
  bastion_security_group_id = module.postgres.bastion_sg_id
  vpc_id                    = data.terraform_remote_state.network.outputs.vpc_id
  vpc_cidr_block            = data.terraform_remote_state.network.outputs.vpc_cidr_block
  private_subnets           = data.terraform_remote_state.network.outputs.private_subnets

  depends_on = [
    module.redis,
    data.terraform_remote_state.network
  ]
}

module "cloudwatch_dashboards" {
  for_each = var.ecs_services
  source   = "../terraform-modules/cloudwatch-dashboard"

  region           = var.region
  alb_name         = module.compute.alb_name
  alb_id           = module.compute.lb_arn_suffix
  ecs_cluster_name = module.container.cluster_name
  ecs_service_name = "${each.key}-${terraform.workspace}"
  dashboard_name   = "${each.key}-${terraform.workspace}-dashboard"

  depends_on = [
    module.container,
    module.compute
  ]
}
