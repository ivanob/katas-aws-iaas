# Define the API Gateway resource
resource "aws_api_gateway_rest_api" "simple_api" {
  name        = "simple_api"
  description = "Example API Gateway"
}

# Define resources and methods
resource "aws_api_gateway_resource" "resource_welcome" {
  rest_api_id = aws_api_gateway_rest_api.simple_api.id
  parent_id   = aws_api_gateway_rest_api.simple_api.root_resource_id
  path_part   = "{${var.resource_welcome}+}"
}

# Define the methods for each resource (entity)
resource "aws_api_gateway_method" "method_get_welcome" {
  rest_api_id   = aws_api_gateway_rest_api.simple_api.id
  resource_id   = aws_api_gateway_resource.resource_welcome.id
  http_method   = "GET"
  authorization = "NONE"
}

# Define integration and deployment for each method
resource "aws_api_gateway_integration" "integration_api_gateway_get_welcome" {
  rest_api_id             = aws_api_gateway_rest_api.simple_api.id
  resource_id             = aws_api_gateway_resource.resource_welcome.id
  http_method             = aws_api_gateway_method.method_get_welcome.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_api_welcomer.invoke_arn
}

# resource "aws_api_gateway_integration" "integration_api_gateway_post_user" {
#   rest_api_id             = aws_api_gateway_rest_api.simple_api.id
#   resource_id             = aws_api_gateway_resource.resource_user.id
#   http_method             = aws_api_gateway_method.method_user_post.http_method
#   integration_http_method = "POST"
#   type                    = "AWS_PROXY"
#   uri                     = aws_lambda_function.lambda_api_replier.invoke_arn
# }

resource "aws_api_gateway_deployment" "gateway_deployment" {
  rest_api_id = aws_api_gateway_rest_api.simple_api.id
  stage_name  = "prod"
  depends_on = [
    aws_api_gateway_method.method_get_welcome,
    aws_api_gateway_integration.integration_api_gateway_get_welcome,
    # aws_api_gateway_integration.integration_api_gateway_post_user
  ]
}

# Permissions to execute the lambda from the gateway
resource "aws_lambda_permission" "permissions_execute_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_api_welcomer.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.simple_api.execution_arn}/*/*/*"
  depends_on = [
    "aws_lambda_function.lambda_api_welcomer",
    "aws_api_gateway_rest_api.simple_api",
    "aws_api_gateway_resource.resource_welcome"
  ]
}
