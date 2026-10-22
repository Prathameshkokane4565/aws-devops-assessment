# Random suffix to ensure unique S3 bucket names globally
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# 1. Application Storage S3 Bucket
resource "aws_s3_bucket" "app_storage" {
  bucket        = "${var.environment}-app-storage-${random_id.bucket_suffix.hex}"
  force_destroy = true

  tags = {
    Name        = "${var.environment}-app-storage"
    Environment = var.environment
  }
}

# Enable Server-Side Encryption (AES256)
resource "aws_s3_bucket_server_side_encryption_configuration" "app_storage_crypto" {
  bucket = aws_s3_bucket.app_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "app_storage_block" {
  bucket = aws_s3_bucket.app_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 2. ALB Access Logs S3 Bucket
resource "aws_s3_bucket" "alb_logs" {
  bucket        = "${var.environment}-alb-logs-${random_id.bucket_suffix.hex}"
  force_destroy = true

  tags = {
    Name        = "${var.environment}-alb-logs"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "alb_logs_crypto" {
  bucket = aws_s3_bucket.alb_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "alb_logs_block" {
  bucket = aws_s3_bucket.alb_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# AWS ELB Account ID for ap-south-1 (Mumbai) is 718504428378
# Bucket policy allowing ALB to write access logs
resource "aws_s3_bucket_policy" "alb_logs_policy" {
  bucket = aws_s3_bucket.alb_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::718504428378:root" # ELB Account ID for ap-south-1
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.alb_logs.arn}/*"
      }
    ]
  })
}

# 3. AWS Secrets Manager for Database Credentials
resource "aws_secretsmanager_secret" "db_secret" {
  name                    = "${var.environment}/rds/mysql"
  recovery_window_in_days = 0

  tags = {
    Name        = "${var.environment}-db-secret"
    Environment = var.environment
  }
}