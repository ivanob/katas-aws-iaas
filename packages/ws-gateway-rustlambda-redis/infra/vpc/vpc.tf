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

# Lambda can send messages back to API Gateway (for WebSocket postToConnection)
resource "aws_security_group_rule" "lambda_to_apigw" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lambda_sg.id
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

# Create the NAT Gateway in a public subnet
# This is needed to allow the Lambda function in the private subnet to access the internet (for API Gateway and CloudWatch Logs)
# The reason for this lambda to access the internet is to be able to call the API Gateway management API to send messages back to clients,
# Yes, this sounds a bit weird, but it's the only way to send messages back to clients from a Lambda function that is not directly invoked by API Gateway (i.e. from the default route handler).

# 1. Create Internet Gateway
resource "aws_internet_gateway" "kata2_igw" {
  vpc_id = aws_vpc.kata2_vpc.id
  
  tags = {
    Name = "kata2-igw"
  }
}

# 2. Create a PUBLIC subnet
resource "aws_subnet" "kata2_public_subnet" {
  vpc_id                  = aws_vpc.kata2_vpc.id
  cidr_block              = "10.0.1.0/24"  # Different from your private subnets
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "kata2-public-subnet"
  }
}

# 3. Create a route table for the public subnet
resource "aws_route_table" "kata2_public_route_table" {
  vpc_id = aws_vpc.kata2_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kata2_igw.id
  }

  tags = {
    Name = "kata2-public-route-table"
  }
}

# 4. Associate the public subnet with the public route table
resource "aws_route_table_association" "kata2_public_subnet_association" {
  subnet_id      = aws_subnet.kata2_public_subnet.id
  route_table_id = aws_route_table.kata2_public_route_table.id
}

# 5. Create Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "kata2-nat-eip"
  }
}

# 6. NOW create the NAT Gateway in the PUBLIC subnet
resource "aws_nat_gateway" "kata2_nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.kata2_public_subnet.id  # Must be the PUBLIC subnet!

  depends_on = [aws_internet_gateway.kata2_igw]

  tags = {
    Name = "kata2-nat-gateway"
  }
}

# 7. Update your PRIVATE route table to route through the NAT Gateway
resource "aws_route" "private_to_nat" {
  route_table_id         = aws_route_table.kata2_private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.kata2_nat.id
}