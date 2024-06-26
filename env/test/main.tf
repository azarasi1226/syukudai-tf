module "network" {
  source = "../../modules/network"

  resource_prefix = var.resource_prefix
  vpc_cidr        = "192.168.0.0/16"
  management_subnet_cidr = "192.168.0.0/24"
  ingress_subnet_cidrs = [
    "192.168.1.0/24",
    "192.168.2.0/24",
    "192.168.3.0/24"
  ]
  private_subnet_cidrs = [
    "192.168.4.0/24",
    "192.168.5.0/24",
    "192.168.6.0/24"
  ]
}

module "jump_server" {
  source = "../../modules/jump_server"

  resource_prefix = var.resource_prefix
  vpc_id          = module.network.vpc_id
  subnet_id       = module.network.management_subnet_id
}

module "nlb" {
  source = "../../modules/nlb"

  resource_prefix = var.resource_prefix
  subnet_ids = module.network.ingress_subnet_ids
  vpc_id = module.network.vpc_id
}

module "ecs" {
  source = "../../modules/ecs"

  resource_prefix = var.resource_prefix
  subnet_ids = module.network.private_subnet_ids
  vpc_id = module.network.vpc_id
  container_port = 80
  blue_targetgroup_arn = module.nlb.blue_targetgroup_arn

  prod_listener_arn      = module.nlb.prod_listener_arn
  test_listener_arn      = module.nlb.test_listener_arn
  blue_targetgroup_name  = module.nlb.blue_targetgroup_name
  green_targetgroup_name = module.nlb.green_targetgroup_name
}