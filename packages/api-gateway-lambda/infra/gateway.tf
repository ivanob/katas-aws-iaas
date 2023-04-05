# Define the API Gateway resource
resource "aws_api_gateway_rest_api" "simple_api" {
  name        = "simple_api"
  description = "Example API Gateway"
}

# Define resources and methods
resource "aws_api_gateway_resource" "resource_user" {
  rest_api_id = aws_api_gateway_rest_api.simple_api.id
  parent_id   = aws_api_gateway_rest_api.simple_api.root_resource_id
  path_part   = "{${var.resource_user}+}"
}

resource "aws_api_gateway_method" "method_user" {
  rest_api_id   = aws_api_gateway_rest_api.simple_api.id
  resource_id   = aws_api_gateway_resource.resource_user.id
  http_method   = "GET"
  authorization = "NONE"
}

# Define integration and deployment
resource "aws_api_gateway_integration" "integration_api_gateway" {
  rest_api_id             = aws_api_gateway_rest_api.simple_api.id
  resource_id             = aws_api_gateway_resource.resource_user.id
  http_method             = aws_api_gateway_method.method_user.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_api_replier.invoke_arn
}

resource "aws_api_gateway_deployment" "gateway_deployment" {
  rest_api_id = aws_api_gateway_rest_api.simple_api.id
  stage_name  = "prod"
  depends_on = [
    aws_api_gateway_method.method_user,
    aws_api_gateway_integration.integration_api_gateway
  ]
}

# This defines the HTTP status code and headers that the API Gateway method returns to the client.
resource "aws_api_gateway_method_response" "method_response" {
  rest_api_id = aws_api_gateway_rest_api.simple_api.id
  resource_id = aws_api_gateway_resource.resource_user.id
  http_method = aws_api_gateway_method.method_user.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

# This defines the HTTP status code and headers that the Lambda function returns to the API Gateway method.
resource "aws_api_gateway_integration_response" "integration_response" {
  rest_api_id = aws_api_gateway_rest_api.simple_api.id
  resource_id = aws_api_gateway_resource.resource_user.id
  http_method = aws_api_gateway_method.method_user.http_method
  status_code = "200"
  response_templates = {
    "application/json" = "$input.json('$')"
  }
  depends_on = [
    "aws_api_gateway_integration.integration_api_gateway"
  ]
}

# Permissions to execute the lambda from the gateway
resource "aws_lambda_permission" "permissions_execute_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_api_replier.function_name}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.simple_api.execution_arn}/${aws_api_gateway_deployment.gateway_deployment.stage_name}/*/*"
  depends_on = [
    "aws_api_gateway_rest_api.simple_api", "aws_api_gateway_resource.resource_user"
  ]
}
