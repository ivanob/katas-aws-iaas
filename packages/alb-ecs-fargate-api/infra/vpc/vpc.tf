resource "aws_vpc" "kata1_vpc" {
  cidr_block = "10.0.0.0/16" # ~65,000 IP addresses

  tags = {
    Name = "kata1-vpc"
  }
}

# Internet Gateway for public subnets
resource "aws_internet_gateway" "kata1_igw" {
  vpc_id = aws_vpc.kata1_vpc.id

  tags = {
    Name = "kata1-igw"
  }
}

# Create a route table for public subnet(s)
resource "aws_route_table" "kata1_public_route_table" {
  vpc_id = aws_vpc.kata1_vpc.id

  tags = {
    Name = "kata1-public-route-table"
  }
}

# Route to Internet Gateway for public subnets
resource "aws_route" "kata1_public_internet_route" {
  route_table_id         = aws_route_table.kata1_public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.kata1_igw.id
}

# Create a route table for private subnet(s)
resource "aws_route_table" "kata1_private_route_table" {
  vpc_id = aws_vpc.kata1_vpc.id

  tags = {
    Name = "kata1-private-route-table"
  }
}

### Allow outbounds from private subnets to internet via NAT Gateway ###
# This means that resources in private subnets can access the internet, 
# but are not directly accessible from the internet.
### This is needed for ECS tasks to pull container images and for updates ###
# Allocate an Elastic IP for the NAT Gateway
resource "aws_eip" "kata1_nat_eip" {
}

# Create the NAT Gateway in a public subnet
resource "aws_nat_gateway" "kata1_nat" {
  allocation_id = aws_eip.kata1_nat_eip.id
  subnet_id     = aws_subnet.kata1_public_subnet1.id

  tags = {
    Name = "kata1-nat-gateway"
  }
}

# Add a route in the private route table for outbound internet
resource "aws_route" "kata1_private_nat_route" {
  route_table_id         = aws_route_table.kata1_private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.kata1_nat.id
}


### DEFINE THE SUBNETS AND ASSOCIATIONS ###
### PUBLIC SUBNETS ###
# Public subnets (for ALB and resources needing internet access)
resource "aws_subnet" "kata1_public_subnet1" {
  vpc_id                  = aws_vpc.kata1_vpc.id
  cidr_block              = "10.0.0.0/24" # 256 IP addresses for public subnet 1
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "kata1-public-subnet1"
  }
}

resource "aws_subnet" "kata1_public_subnet2" {
  vpc_id                  = aws_vpc.kata1_vpc.id
  cidr_block              = "10.0.1.0/24" # 256 IP addresses for public subnet 2
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "kata1-public-subnet2"
  }
}

# Associate the public subnets with the public route table
resource "aws_route_table_association" "kata1_public_subnet1_association" {
  subnet_id      = aws_subnet.kata1_public_subnet1.id
  route_table_id = aws_route_table.kata1_public_route_table.id
}

resource "aws_route_table_association" "kata1_public_subnet2_association" {
  subnet_id      = aws_subnet.kata1_public_subnet2.id
  route_table_id = aws_route_table.kata1_public_route_table.id
}

### PRIVATE SUBNETS ###
# Associate the private subnets with the private route table
resource "aws_route_table_association" "kata1_private_subnet1_association" {
  subnet_id      = aws_subnet.kata1_private_subnet1.id
  route_table_id = aws_route_table.kata1_private_route_table.id
}

resource "aws_route_table_association" "kata1_private_subnet2_association" {
  subnet_id      = aws_subnet.kata1_private_subnet2.id
  route_table_id = aws_route_table.kata1_private_route_table.id
}

# Private subnets (for EC2 and ECS)
resource "aws_subnet" "kata1_private_subnet1" {
  vpc_id            = aws_vpc.kata1_vpc.id
  cidr_block        = "10.0.2.0/24" # 256 IP addresses for private subnet 1
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "kata1-private-subnet1"
  }
}

resource "aws_subnet" "kata1_private_subnet2" {
  vpc_id            = aws_vpc.kata1_vpc.id
  cidr_block        = "10.0.3.0/24" # 256 IP addresses for private subnet 2
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "kata1-private-subnet2"
  }
}

# This data source is used to get the list of available availability zones in the region
data "aws_availability_zones" "available" {}