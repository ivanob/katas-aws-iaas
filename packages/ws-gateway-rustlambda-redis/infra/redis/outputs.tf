output "redis_endpoint" {
  description = "The endpoint of the Redis cluster (without the port)"
  value       = aws_elasticache_cluster.redis_cluster.cache_nodes[0].address
}