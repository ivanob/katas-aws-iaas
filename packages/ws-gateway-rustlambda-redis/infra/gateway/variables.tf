variable "vpc_id" {
  description = "The ID of the VPC where the Redis cluster is deployed"
  type        = string
}

variable "redis_endpoint" {
  description = "The endpoint of the Redis cluster (without the port)"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs for the Lambda function to access Redis"
  type        = list(string)
}

variable "vpc_subnet_ids" {
  description = "List of subnet IDs for the Lambda function to access Redis"
  type        = list(string)
}