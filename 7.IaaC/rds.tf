
# Create Subnet Group for DB
resource "aws_db_subnet_group" "db_subnetgroup" {
  name       = "${var.env_prefix}-db-subnet-group"
  subnet_ids = [for subnet in aws_subnet.private_subnet : subnet.id]

  tags = {
    Name = "${var.env_prefix}-db-subnet-group"
  }
}

# Create RDS Instance
resource "aws_db_instance" "rds" {
  engine                 = "postgres"
  engine_version         = "15.3"
  identifier             = "db-postgresql"
  multi_az               = false
  username               = "postgres"
  password               = "somepassword"
  instance_class         = "db.t3.micro"
  storage_type           = "gp2"
  allocated_storage      = 20
  db_subnet_group_name   = aws_db_subnet_group.db_subnetgroup.name
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.db-postgresql.id]
}
