output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.kata1_vpc.id
}

output "public_subnet1_id" {
  description = "The ID of public subnet 1"
  value       = aws_subnet.kata1_public_subnet1.id
}

output "public_subnet2_id" {
  description = "The ID of public subnet 2"
  value       = aws_subnet.kata1_public_subnet2.id
}

output "private_subnet1_id" {
  description = "The ID of private subnet 1"
  value       = aws_subnet.kata1_private_subnet1.id
}

output "private_subnet2_id" {
  description = "The ID of private subnet 2"
  value       = aws_subnet.kata1_private_subnet2.id
}
