output "alb_dns_name" {
  description = "Public DNS of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "application_url" {
  description = "Endpoint to test the application"
  value       = "http://${module.alb.alb_dns_name}"
}

output "rds_endpoint" {
  description = "RDS MySQL Host Address"
  value       = module.database.rds_endpoint
}

output "secrets_manager_name" {
  description = "Secrets Manager secret key name"
  value       = module.storage.db_secret_name
}