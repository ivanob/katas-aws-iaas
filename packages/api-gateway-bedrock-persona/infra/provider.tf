provider "aws" {
  profile = "default"
  region = "eu-west-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.35"  # or "= 6.35.1" for exact version
    }
  }
  required_version = ">= 1.0"
}