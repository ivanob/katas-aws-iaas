output "vpc_id" {
    description = "The ID of the VPC"
    value       = aws_vpc.kata2_vpc.id
}

output "private_subnet_id" {
    description = "The ID of private subnet 1"
    value       = aws_subnet.kata2_private_subnet1.id
}

output "redis_sg_id" {
    description = "Security Group ID of the Redis cluster"
    value       = aws_security_group.redis_sg.id
}

output "lambda_sg_id" {
    description = "Security Group ID of the Lambda function that needs access to Redis"
    value       = aws_security_group.lambda_sg.id
}   