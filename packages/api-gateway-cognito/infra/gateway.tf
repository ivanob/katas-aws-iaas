# Define the API Gateway resource
resource "aws_api_gateway_rest_api" "simple_api_auth" {
  name        = "simple_api_auth"
  description = "Example API Gateway cognito authorizer"
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
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.api_authorizer.id # This is the authorization by cognito
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_authorizer" "api_authorizer" {
  name          = "CognitoUserPoolAuthorizer"
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = aws_api_gateway_rest_api.simple_api_auth.id
  provider_arns = [aws_cognito_user_pool.user_pool.arn]
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

# Create a stage deployment; in this case prod directly
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
  source_arn    = "${aws_api_gateway_rest_api.simple_api_auth.execution_arn}/*"
  depends_on = [
    "aws_lambda_function.lambda_api_welcomer",
    "aws_api_gateway_rest_api.simple_api_auth",
    "aws_api_gateway_resource.resource_welcome"
  ]
}
