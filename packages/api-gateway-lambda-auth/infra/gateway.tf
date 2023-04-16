# Define the API Gateway resource
resource "aws_api_gateway_rest_api" "simple_api_auth" {
  name        = "simple_api_auth"
  description = "Example API Gateway lambda authorizer"
}

# Define resources and methods
resource "aws_api_gateway_resource" "resource_welcome" {
  rest_api_id = aws_api_gateway_rest_api.simple_api_auth.id
  parent_id   = aws_api_gateway_rest_api.simple_api_auth.root_resource_id
  path_part   = "{${var.resource_welcome}+}"
}

# Define the methods for each resource (entity)
resource "aws_api_gateway_method" "method_get_welcome" {
  rest_api_id   = aws_api_gateway_rest_api.simple_api_auth.id
  resource_id   = aws_api_gateway_resource.resource_welcome.id
  http_method   = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.lambda_authorizer.id # This is my custom lambda authorizer, to protect this endpoint
}

# Define integration and deployment for each method
resource "aws_api_gateway_integration" "integration_api_gateway_get_welcome" {
  rest_api_id             = aws_api_gateway_rest_api.simple_api_auth.id
  resource_id             = aws_api_gateway_resource.resource_welcome.id
  http_method             = aws_api_gateway_method.method_get_welcome.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_api_welcomer.invoke_arn
}

resource "aws_api_gateway_deployment" "gateway_deployment" {
  rest_api_id = aws_api_gateway_rest_api.simple_api_auth.id
  stage_name  = "prod"
  depends_on = [
    aws_api_gateway_method.method_get_welcome,
    aws_api_gateway_integration.integration_api_gateway_get_welcome
  ]
}

# Permissions to execute the lambda from the gateway
resource "aws_lambda_permission" "permissions_execute_lambda_welcomer" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_api_welcomer.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.simple_api_auth.execution_arn}/*/*/*"
  depends_on = [
    "aws_lambda_function.lambda_api_welcomer",
    "aws_api_gateway_rest_api.simple_api_auth",
    "aws_api_gateway_resource.resource_welcome"
  ]
}
resource "aws_lambda_permission" "apigw_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auth_lambda.arn

  principal = "apigateway.amazonaws.com"

  source_arn = aws_api_gateway_rest_api.simple_api_auth.execution_arn
}

# Create the Lambda authorizer for the API Gateway
resource "aws_api_gateway_authorizer" "lambda_authorizer" {
  name          = "my_lambda_authorizer"
  rest_api_id   = aws_api_gateway_rest_api.simple_api_auth.id
  authorizer_uri = aws_lambda_function.auth_lambda.invoke_arn
  authorizer_result_ttl_in_seconds = 300 # Optional: specify a result cache TTL for the authorizer
  identity_source = "method.request.header.authorizationToken" # Has to match the parameter I am expecting in the auth_lambda in the headers

  # Define the type of the authorizer, such as "TOKEN" or "REQUEST"
  # For example, you can use "TOKEN" for JWT-based authentication or "REQUEST" for custom request-based authentication
  type = "REQUEST"
}