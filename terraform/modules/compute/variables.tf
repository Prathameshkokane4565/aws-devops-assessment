variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "private_app_subnet_ids" {
  description = "Private Subnet IDs for EC2 instances"
  type        = list(string)
}

variable "ec2_security_group_id" {
  description = "Security Group ID for EC2 instances"
  type        = string
}

variable "ec2_instance_profile_name" {
  description = "IAM Instance Profile Name for EC2"
  type        = string
}

variable "target_group_arn" {
  description = "ALB Target Group ARN"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance size"
  type        = string
  default     = "t3.micro"
}