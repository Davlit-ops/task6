terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket       = "aws-task6-eks"
    key          = "dev/terraform.tfstate"
    region       = "us-east-2"
    encrypt      = true
    use_lockfile = true
    profile      = "task6"
  }
}

provider "aws" {
  region  = var.region
  profile = "task6"

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      Owner       = "vdavl"
      ManagedBy   = "Terraform"
    }
  }
}
