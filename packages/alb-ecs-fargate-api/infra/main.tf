terraform {
  required_version = ">= 1.3"
}

module "vpc" {
  source = "./vpc"
}   

module "alb_ecs_fargate" {
  source = "./ALB"

  vpc_id            = module.vpc.vpc_id
  public_subnet1_id = module.vpc.public_subnet1_id
  public_subnet2_id = module.vpc.public_subnet2_id
#   private_subnet1_id = module.vpc.private_subnet1_id
#   private_subnet2_id = module.vpc.private_subnet2_id
}   


module "ecs" {
  source = "./ecs"

  vpc_id                 = module.vpc.vpc_id
  private_subnet_ids     = [module.vpc.private_subnet1_id, module.vpc.private_subnet2_id]
  alb_security_group_id  = module.ALB.alb_security_group_id
  target_group_arn       = module.ALB.target_group_arn
  alb_listener_arn       = module.ALB.alb_listener_arn
  docker_image           = var.docker_image
  aws_region             = var.aws_region
}