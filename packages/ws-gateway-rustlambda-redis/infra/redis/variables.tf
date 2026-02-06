
variable "vpc_id" {
  description = "The ID of the VPC where the Redis cluster is deployed"
  type        = string
}

variable "private_subnet_id" {
  description = "The ID of the private subnet where the Redis cluster is deployed"
  type        = string
}

variable "redis_sg_id" {
  description = "The ID of the security group associated with the Redis cluster"
  type        = string
}