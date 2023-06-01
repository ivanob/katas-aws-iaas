# Define the API Gateway resource
resource "aws_api_gateway_rest_api" "gateway_to_s3" {
  name        = "gateway_to_s3"
  description = "Example API Gateway proxy to s3"
}

# Define resources and methods

# resource "aws_api_gateway_resource" "Item" {
#   rest_api_id = aws_api_gateway_rest_api.gateway_to_s3.id
#   parent_id   = aws_api_gateway_rest_api.gateway_to_s3.root_resource_id
#   path_part   = "{item+}"
# }

# resource "aws_api_gateway_method" "method_post_doc" {
#   rest_api_id   = aws_api_gateway_rest_api.gateway_to_s3.id
#   resource_id   = aws_api_gateway_resource.Item.id
#   http_method   = "POST"
#   authorization = "NONE"
# }

# resource "aws_api_gateway_method" "method_get_doc" {
#   rest_api_id   = aws_api_gateway_rest_api.gateway_to_s3.id
#   resource_id   = aws_api_gateway_resource.Item.id
#   http_method   = "GET" # Replace with your desired HTTP method
#   authorization = "NONE"
# }

# # Define the integration between method, gateway and resource
# resource "aws_api_gateway_integration" "method_post_item" {
#   rest_api_id             = aws_api_gateway_rest_api.gateway_to_s3.id
#   resource_id             = aws_api_gateway_resource.Item.id
#   http_method             = aws_api_gateway_method.method_post_doc.http_method
#   integration_http_method = "POST"
#   type                    = "AWS" # This is a proxy gateway to s3
#   uri                     = "arn:aws:apigateway:${var.aws_region}:s3:path//"
#   credentials             = aws_iam_role.s3_api_gateway_role.arn
# }

# resource "aws_api_gateway_integration" "my_integration" {
#   rest_api_id             = aws_api_gateway_rest_api.gateway_to_s3.id
#   resource_id             = aws_api_gateway_method.method_get_doc.resource_id
#   http_method             = aws_api_gateway_method.method_get_doc.http_method
#   type                    = "AWS"
#   integration_http_method = "GET" # Replace with your desired HTTP method for the integration

#   uri = "arn:aws:apigateway:${var.aws_region}:s3:path/{folder}/"
#   credentials             = aws_iam_role.s3_api_gateway_role.arn
# }
