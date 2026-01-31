# Security Group for ALB
resource "aws_security_group" "kata1_alb_sg" {
  name        = "kata1-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "kata1-alb-sg"
  }
}

# Application Load Balancer
resource "aws_lb" "kata1_alb" {
  name               = "kata1-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.kata1_alb_sg.id]
  subnets            = [var.public_subnet1_id, var.public_subnet2_id]

  enable_deletion_protection = false

  tags = {
    Name = "kata1-alb"
  }
}

# Target Group (for ECS tasks)
resource "aws_lb_target_group" "kata1_tg" {
  name        = "kata1-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip" # Use 'ip' for Fargate

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200"
  }

  tags = {
    Name = "kata1-target-group"
  }
}

# ALB Listener (HTTP)
resource "aws_lb_listener" "kata1_http" {
  load_balancer_arn = aws_lb.kata1_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kata1_tg.arn
  }
}
