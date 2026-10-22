output "app_bucket_name" {
  value = aws_s3_bucket.app_storage.bucket
}

output "alb_logs_bucket_name" {
  value = aws_s3_bucket.alb_logs.bucket
}

output "db_secret_name" {
  value = aws_secretsmanager_secret.db_secret.name
}

output "db_secret_arn" {
  value = aws_secretsmanager_secret.db_secret.arn
}