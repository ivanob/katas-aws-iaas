terraform {
  required_version = ">= 1.3"
}

module "gateway"{
    source = "./gateway"
    vpc_id = module.vpc.vpc_id
    redis_endpoint = module.redis.redis_endpoint
    depends_on = [ module.vpc ]
}

module "vpc" {
    source = "./vpc"
} 

module "redis" {
    source = "./redis"
    vpc_id = module.vpc.vpc_id
    private_subnet_id = module.vpc.private_subnet_id
    redis_sg_id = module.vpc.lambda_sg_id
    depends_on = [ module.vpc ]
} 