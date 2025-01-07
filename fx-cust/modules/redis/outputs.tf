output "cache_nodes" {
    value = aws_elasticache_cluster.redis.cache_nodes
}

output "cluster_id" {
    value = aws_elasticache_cluster.redis.cluster_id
}

output "arn" {
    value = aws_elasticache_cluster.redis.arn
}