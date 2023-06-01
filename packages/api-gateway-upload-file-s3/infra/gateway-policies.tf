
# # Create API Gateway Role
# resource "aws_iam_role" "s3_api_gateway_role" {
#   name = "s3-api-gateway-role"

#   # Create Trust Policy for API Gateway
#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Sid": "",
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "apigateway.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# EOF
# }
