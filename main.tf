terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}

# ローカル変数
locals {
  app_name = "${var.project_name}-${var.environment}"
  azs      = data.aws_availability_zones.available.names
}

# 利用可能な AZ を取得
data "aws_availability_zones" "available" {
  state = "available"
}
