variable "iam_lambda_role_id" {
  description = "The id of the IAM role"
  type        = string
}

variable "function_name" {
    description = "Name of the lambda"
    type = string
}

# variable "services" {
#   description = "List of services that can assume the role"
#   type        = list(string)
# }
locals {
  env = terraform.workspace  # Will be "dev" or "prod"
}