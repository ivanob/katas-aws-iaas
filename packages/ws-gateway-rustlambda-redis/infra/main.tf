terraform {
  required_version = ">= 1.3"
}

module "gateway"{
    source = "./gateway"
}