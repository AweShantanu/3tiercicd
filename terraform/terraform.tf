terraform {
  backend "s3" {
    bucket = "3tiercicd-terraform-backend-bucket0"
    key    = "s3-backend"
    region = "us-east-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.52.0, < 7.0.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

