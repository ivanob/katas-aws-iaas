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


<h3>How to push the local docker image to the AWS repo (ECR)</h3>
<h4>Create repository</h4>

```
aws ecr create-repository --repository-name kata1-api --region eu-north-1
```

<h4>Authenticate docker to ECR</h4>

```
aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin <your-account-id>.dkr.ecr.eu-north-1.amazonaws.com
```

<h4>Create the image</h4>

```
docker buildx build \
  --platform linux/amd64 \
  -t kata1-rust-api:latest \
  .
```

<h4>Tag the image to ECR</h4>

```
docker tag kata1-rust-api:latest <your-account-id>.dkr.ecr.eu-north-1.amazonaws.com/kata1-api:latest
```

<h4>Push the Image to ECR</h4>

```
docker push <your-account-id>.dkr.ecr.eu-north-1.amazonaws.com/kata1-api:latest
```

<h3>Config</h3>
Create a terraform.tfvars file in the infra folder of this kata with this format
```
account_id="123456..."
region="eu-north-1"
```

<h2>How to test that it all works?</h2>
You can access from the browser to http://kata1-alb-[AWS_ACCOUNT_ID].eu-north-1.elb.amazonaws.com/