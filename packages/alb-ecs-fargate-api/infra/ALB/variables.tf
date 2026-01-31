variable "vpc_id"{
    description = "The ID of the VPC where to deploy the ALB and ECS Fargate resources"
    type        = string
}

variable "public_subnet1_id" {
    description = "The ID of public subnet 1"
    type        = string
}

variable "public_subnet2_id" {
    description = "The ID of public subnet 2"
    type        = string
}