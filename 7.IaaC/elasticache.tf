# ---------------------
# Create Redis db
# ---------------------

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "redis-cluster"
  engine               = "redis"
  node_type            = "cache.t4g.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  az_mode              = "single-az"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.redis_subnet.name
  security_group_ids   = [aws_security_group.db-redis.id]
}

resource "aws_elasticache_subnet_group" "redis_subnet" {
  name       = "redis-subnet"
  subnet_ids = [aws_subnet.private_subnet[0].id]
}

# ---------------------
# Create Memcached db
# ---------------------

resource "aws_elasticache_cluster" "memcached" {
  cluster_id           = "memcached-cluster"
  engine               = "memcached"
  node_type            = "cache.t4g.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.memcached1.6"
  az_mode              = "single-az"
  port                 = 11211
  subnet_group_name    = aws_elasticache_subnet_group.memcached_subnet.name
  security_group_ids   = [aws_security_group.db-memcached.id]
}

resource "aws_elasticache_subnet_group" "memcached_subnet" {
  name       = "memcached-subnet"
  subnet_ids = [aws_subnet.private_subnet[1].id]
}
