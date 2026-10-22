variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "app_port" {
  description = "Port on which the application listens"
  type        = number
  default     = 80
}