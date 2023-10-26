locals {

}

# ---------------------
# Security group for SSH access
# ---------------------
resource "aws_security_group" "ssh-in" {
  name        = "ssh-in-sg"
  description = "Access by ssh from whitelisted IPs"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "SSH from admin IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip]
  }

  tags = {
    Name = "ssh-in-sg"
  }
}

# ---------------------
# Security group for HTTP/HTTPS from LoadBalancer
# ---------------------
resource "aws_security_group" "web" {
  name        = "web-sg"
  description = "Access to web servers"
  vpc_id      = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = ["80", "443"]
    content {
      description     = "HTTP/HHTPS from load balancer"
      from_port       = ingress.value
      to_port         = ingress.value
      protocol        = "tcp"
      security_groups = [aws_security_group.load_balancer.id]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}

# ---------------------
# Security group for all inbound HTTP/HTTPS
# ---------------------
resource "aws_security_group" "load_balancer" {
  name        = "elb-sg"
  description = "Access to load balancer"
  vpc_id      = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = ["80", "443"]
    content {
      description = "HTTPS from internet"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "elb-sg"
  }
}

# ---------------------
# Security group for PostgreSQL
# ---------------------
resource "aws_security_group" "db-postgresql" {
  name        = "db-sg"
  description = "Access to db servers"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "Connections to PostgreSQL from web-servers"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db-sg"
  }
}

# ---------------------
# Security group for Redis db
# ---------------------
resource "aws_security_group" "db-redis" {
  name        = "redis-sg"
  description = "Access to redis"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "Connections to Redis from web-servers"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "redis-sg"
  }
}

# ---------------------
# Security group for Memcached db
# ---------------------
resource "aws_security_group" "db-memcached" {
  name        = "memcached-sg"
  description = "Access to Memcached"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "Connections to Memcached from web-servers"
    from_port       = 11211
    to_port         = 11211
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "memcached-sg"
  }
}
