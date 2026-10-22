terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "DevOps-Assessment"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# 1. VPC Module
module "vpc" {
  source      = "./modules/vpc"
  environment = var.environment
}

# 2. Security Module
module "security" {
  source      = "./modules/security"
  vpc_id      = module.vpc.vpc_id
  environment = var.environment
  app_port    = 80
}

# 3. Storage Module (S3 + Secrets Manager)
module "storage" {
  source      = "./modules/storage"
  environment = var.environment
  aws_region  = var.aws_region
}

# 4. Database Module (RDS MySQL)
module "database" {
  source                = "./modules/database"
  environment           = var.environment
  private_db_subnet_ids = module.vpc.private_db_subnet_ids
  rds_security_group_id = module.security.rds_security_group_id
  secret_id             = module.storage.db_secret_name
  db_name               = "appdb"
  db_username           = "admin"
}

# 5. ALB Module
module "alb" {
  source                = "./modules/alb"
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
  alb_logs_bucket       = module.storage.alb_logs_bucket_name
  certificate_arn       = var.certificate_arn
}

# 6. Compute Module (Auto Scaling Group)
module "compute" {
  source                    = "./modules/compute"
  environment               = var.environment
  private_app_subnet_ids    = module.vpc.private_app_subnet_ids
  ec2_security_group_id     = module.security.ec2_security_group_id
  ec2_instance_profile_name = module.security.ec2_instance_profile_name
  target_group_arn          = module.alb.target_group_arn
  instance_type             = "t3.micro"
}