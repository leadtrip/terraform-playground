terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

module "logs_bucket" {
  source = "../modules/s3-logs-bucket"

  bucket_name       = "mike-demo-logs-bucket-12345"
  enable_versioning = true

  tags = {
    Project = "terraform-module-demo"
    Owner   = "mike"
  }
}

output "logs_bucket_name" {
  value = module.logs_bucket.bucket_id
}