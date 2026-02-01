This is an implementation of an API in RUST following this schema:

ALB (Elastic Load Balancer) -> ECS -> Fargate -> Docker image

The docker image will contain a very simple API written in Rust.

Infrastructure Components
1. VPC Module (vpc/)
VPC with CIDR 10.0.0.0/16
Internet Gateway
2 Public Subnets (10.0.0.0/24, 10.0.1.0/24) with IGW route
2 Private Subnets (10.0.2.0/24, 10.0.3.0/24) - no internet access
Public & Private Route Tables with associations
Outputs: VPC ID, subnet IDs
2. ALB Module (ALB/)
Security Group (allows HTTP/HTTPS inbound, all outbound)
Application Load Balancer (internet-facing, in public subnets)
Target Group (IP-based for Fargate, health checks on /)
HTTP Listener (port 80 → target group)
Variables & outputs defined
3. Main Configuration (main.tf)
Calls VPC module
Calls ALB module (passing VPC outputs)
S3 backend commented out (using local state)
4. Provider (providers.tf)
AWS provider configured for eu-north-1
