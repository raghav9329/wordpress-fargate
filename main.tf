data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}

locals {
  prefix   = var.prefix
  vpc_name = "${var.vpc_namespace}" # this variables is local.vpc_name
  vpc_cidr = var.vpc_cidr
  common_tags = {
    Environment = "demo"
    Project     = "${var.vpc_namespace}"
  }
}


module "vpc_main" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.16.0"

  create_vpc                             = true
  create_igw                             = true
  create_database_internet_gateway_route = true
  name                                   = local.vpc_name
  cidr                                   = var.vpc_cidr
  azs                                    = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets                        = var.private_subnets
  private_subnet_suffix                  = "private"
  public_subnets                         = var.public_subnets
  public_subnet_suffix                   = "public"
  map_public_ip_on_launch                = true

  enable_nat_gateway     = var.enable_nat
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  # Default security group - ingress/egress rules cleared to deny all
  manage_default_security_group  = true
  default_security_group_ingress = []
  default_security_group_egress  = []
  enable_dns_support             = true
  enable_dns_hostnames           = true

  tags = merge(
    {
      Owner = "raghav_pandey"
    },
    local.common_tags
  )

}

module "alb" {
  source = "./modules/alb"

  vpc_namespace     = var.vpc_namespace
  private_subnets   = module.vpc_main.private_subnets
  public_subnets    = module.vpc_main.public_subnets
  vpc_id            = module.vpc_main.vpc_id
  app_port          = var.app_port
  health_check_path = var.health_check_path

}

// MODULE RDS 
module "rds" {
  source = "./modules/rds"

  vpc_id               = module.vpc_main.vpc_id
  vpc_namespace        = var.vpc_namespace
  rds_port             = var.rds_port
  vpc_cidr             = var.vpc_cidr
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = var.db_password
  db_subnet_group_name = var.db_subnet_group_name
  private_subnets      = module.vpc_main.private_subnets
  region               = var.region
  instance_class       = var.instance_class
}



// MODULE EVERYTHING ECS - FARGATE

module "fargate_dev" {
  source     = "./modules/fargate"
  depends_on = [module.alb]

  region                = var.region
  vpc_id                = module.vpc_main.vpc_id
  app_name              = var.app_name
  app_image             = var.app_image
  app_port              = var.app_port
  fargate_memory        = var.fargate_memory
  fargate_cpu           = var.fargate_cpu
  app_count             = var.app_count
  az_count              = var.app_count
  private_subnets       = module.vpc_main.private_subnets
  public_subnets        = module.vpc_main.public_subnets
  alb_security_group_id = [module.alb.alb_security_group_id]
  alb_target_group_arn  = module.alb.alb_target_group_arn
  rds_endpoint          = module.rds.rds_endpoint
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = var.db_password
  // EFS INPUTS
  efs_id           = module.efs_dev.id
  efs_access_point = module.efs_dev.access_point_ids["mnt/efs"]
  volume_name      = var.volume_name
}

# *****                     EFS MODULE                                   *****
module "efs_dev" {
  source = "cloudposse/efs/aws"
  # Cloud Posse recommends pinning every module to a specific version
  # version     = "x.x.x"

  namespace             = var.app_name
  stage                 = "test"
  name                  = var.vpc_namespace
  region                = var.region
  vpc_id                = module.vpc_main.vpc_id
  subnets               = module.vpc_main.private_subnets
  encrypted             = true
  create_security_group = true
  allowed_cidr_blocks   = [var.vpc_cidr]

  access_points = {
    "mnt/efs" = {
      posix_user = {
        gid            = "1001"
        uid            = "5000"
        secondary_gids = "1002,1003"
      }
      creation_info = {
        gid         = "1001"
        uid         = "5000"
        permissions = "0755"
      }
    }
  }
}
