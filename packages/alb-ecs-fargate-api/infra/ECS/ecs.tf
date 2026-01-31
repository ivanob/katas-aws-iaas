# ECS Cluster
resource "aws_ecs_cluster" "kata1_cluster" {
  name = "kata1-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "kata1-ecs-cluster"
  }
}

# ECS Task Execution Role (for pulling images, logging)
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "kata1-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "kata1-ecs-task-execution-role"
  }
}

# Attach AWS managed policy for ECS task execution
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Role (for your application to access AWS services)
resource "aws_iam_role" "ecs_task_role" {
  name = "kata1-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "kata1-ecs-task-role"
  }
}

# Security Group for ECS Tasks
resource "aws_security_group" "ecs_tasks_sg" {
  name        = "kata1-ecs-tasks-sg"
  description = "Security group for ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow traffic from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "kata1-ecs-tasks-sg"
  }
}

# CloudWatch Log Group for ECS tasks
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/kata1-api"
  retention_in_days = 7

  tags = {
    Name = "kata1-ecs-logs"
  }
}

# ECS Task Definition
resource "aws_ecs_task_definition" "kata1_api" {
  family                   = "kata1-api"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"  # 0.25 vCPU
  memory                   = "512"  # 512 MB
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "kata1-api-container"
      image     = var.docker_image # You'll need to provide this
      essential = true
      
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }

      environment = [
        {
          name  = "ENVIRONMENT"
          value = "production"
        }
      ]
    }
  ])

  tags = {
    Name = "kata1-api-task-definition"
  }
}

# ECS Service
resource "aws_ecs_service" "kata1_api_service" {
  name            = "kata1-api-service"
  cluster         = aws_ecs_cluster.kata1_cluster.id
  task_definition = aws_ecs_task_definition.kata1_api.arn
  desired_count   = 2  # Run 2 tasks for HA
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_tasks_sg.id]
    assign_public_ip = false  # Tasks in private subnets
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "kata1-api-container"
    container_port   = 80
  }

  depends_on = [var.alb_listener_arn]

  tags = {
    Name = "kata1-api-service"
  }
}