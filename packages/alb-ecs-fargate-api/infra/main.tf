terraform {
  required_version = ">= 1.3"
}

module "vpc" {
  source = "./vpc"
}   