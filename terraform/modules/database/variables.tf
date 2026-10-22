variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "private_db_subnet_ids" {
  description = "Private Subnet IDs for RDS Subnet Group"
  type        = list(string)
}

variable "rds_security_group_id" {
  description = "Security Group ID for RDS"
  type        = string
}

variable "secret_id" {
  description = "Secrets Manager Secret ID to store DB credentials"
  type        = string
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Master database username"
  type        = string
  default     = "admin"
}