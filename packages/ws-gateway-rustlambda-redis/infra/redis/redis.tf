

resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "kata2-redis-subnet-group"
  subnet_ids = [var.private_subnet_id]

  tags = {
    Name = "Redis subnet group"
  }
}

resource "aws_elasticache_cluster" "redis_cluster" {
  cluster_id           = "kata2-ticketing-redis"
  engine               = "redis"
  node_type            = "cache.t3.micro" # Use larger for prod
  num_cache_nodes      = 1                # Use replication group for HA
  parameter_group_name = "default.redis7"
  port                 = 6379

  subnet_group_name    = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids   = [var.redis_sg_id]

  lifecycle {
    prevent_destroy = true
  }
  depends_on = [
    aws_elasticache_subnet_group.redis_subnet_group
  ]
}
