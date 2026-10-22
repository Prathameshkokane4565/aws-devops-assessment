variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public Subnet IDs for ALB"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security Group ID for ALB"
  type        = string
}

variable "alb_logs_bucket" {
  description = "S3 Bucket name for ALB Access Logs"
  type        = string
}

variable "certificate_arn" {
  description = "ACM Certificate ARN for HTTPS listener (optional for testing)"
  type        = string
  default     = ""
}