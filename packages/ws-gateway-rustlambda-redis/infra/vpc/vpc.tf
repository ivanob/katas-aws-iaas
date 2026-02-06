resource "aws_vpc" "kata2_vpc" {
  cidr_block = "10.0.0.0/16" # ~65,000 IP addresses

  tags = {
    Name = "kata2-vpc"
  }
}

# Create a route table for private subnet(s)
resource "aws_route_table" "kata2_private_route_table" {
  vpc_id = aws_vpc.kata2_vpc.id
  tags = {
    Name = "kata2-private-route-table"
  }
}

### DEFINE THE SUBNETS AND ASSOCIATIONS ###
### PRIVATE SUBNETS ###
# Associate the private subnets with the private route table
resource "aws_route_table_association" "kata2_private_subnet1_association" {
  subnet_id      = aws_subnet.kata2_private_subnet1.id
  route_table_id = aws_route_table.kata2_private_route_table.id
}

# Private subnets (for EC2 and ECS)
resource "aws_subnet" "kata2_private_subnet1" {
  vpc_id            = aws_vpc.kata2_vpc.id
  cidr_block        = "10.0.2.0/24" # 256 IP addresses for private subnet 1
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "kata2-private-subnet1"
  }
}

# This data source is used to get the list of available availability zones in the region
data "aws_availability_zones" "available" {}


# Now I define the Security Group for Redis in the Redis module, and I need to pass the VPC ID and Lambda SG ID from the VPC and Gateway modules respectively. I will output these values from their respective modules and use them as inputs in the Redis module.
# Lambda Security Group (no inline rules)
resource "aws_security_group" "lambda_sg" {
  name        = "kata2-lambda-sg"
  description = "Security group for Lambda"
  vpc_id      = aws_vpc.kata2_vpc.id
}

# Redis Security Group (no inline rules)
resource "aws_security_group" "redis_sg" {
  name        = "kata2-redis-sg"
  description = "Security group for Redis"
  vpc_id      = aws_vpc.kata2_vpc.id
}

# Lambda can talk to Redis on port 6379
resource "aws_security_group_rule" "lambda_to_redis" {
  type                     = "egress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.lambda_sg.id
  source_security_group_id = aws_security_group.redis_sg.id
}

# Redis accepts traffic from Lambda on port 6379
resource "aws_security_group_rule" "redis_from_lambda" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.redis_sg.id
  source_security_group_id = aws_security_group.lambda_sg.id
}

# Redis can send responses back
resource "aws_security_group_rule" "redis_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.redis_sg.id
}