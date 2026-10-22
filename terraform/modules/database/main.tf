# Generate strong random password for DB
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# 1. DB Subnet Group (Across Private Subnets)
resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "${var.environment}-rds-subnet-group"
  subnet_ids  = var.private_db_subnet_ids
  description = "Subnet group for RDS MySQL in private subnets"

  tags = {
    Name        = "${var.environment}-rds-subnet-group"
    Environment = var.environment
  }
}

# 2. RDS MySQL Instance
resource "aws_db_instance" "mysql" {
  identifier             = "${var.environment}-mysql-db"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  max_allocated_storage  = 50
  storage_type           = "gp3"
  db_name                = var.db_name
  username               = var.db_username
  password               = random_password.db_password.result
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [var.rds_security_group_id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  multi_az               = false # Cost-efficient for assessment demo, easily switchable to true

  tags = {
    Name        = "${var.environment}-mysql"
    Environment = var.environment
  }
}

# 3. Store Database Connection details in Secrets Manager
resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = var.secret_id
  secret_string = jsonencode({
    host     = aws_db_instance.mysql.address
    port     = aws_db_instance.mysql.port
    dbname   = var.db_name
    username = var.db_username
    password = random_password.db_password.result
  })
}