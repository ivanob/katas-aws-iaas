variable "vpc_id" {
  description = "The ID of the VPC where the Redis cluster is deployed"
  type        = string
}

variable "redis_endpoint" {
  description = "The endpoint of the Redis cluster (without the port)"
  type        = string
}