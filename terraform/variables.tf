variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "certificate_arn" {
  description = "ACM Certificate ARN for HTTPS (leave empty if not configured)"
  type        = string
  default     = ""
}