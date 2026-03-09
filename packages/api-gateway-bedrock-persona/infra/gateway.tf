# Define the API Gateway resource
resource "aws_api_gateway_rest_api" "kata_api_to_persona" {
  name        = "kata_api_to_persona"
  description = "API Gateway for AI conversation handling"
}

# Define resources and methods
resource "aws_api_gateway_resource" "resource_conversation" {
  rest_api_id = aws_api_gateway_rest_api.kata_api_to_persona.id
  parent_id   = aws_api_gateway_rest_api.kata_api_to_persona.root_resource_id
  path_part   = "{conversation+}"
}

# Define the methods for each resource (entity)
resource "aws_api_gateway_method" "method_conversation_get" {
  rest_api_id   = aws_api_gateway_rest_api.kata_api_to_persona.id
  resource_id   = aws_api_gateway_resource.resource_conversation.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "method_conversation_post" {
  rest_api_id   = aws_api_gateway_rest_api.kata_api_to_persona.id
  resource_id   = aws_api_gateway_resource.resource_conversation.id
  http_method   = "POST"
  authorization = "NONE"
}

# Define integration and deployment for each method
# For simplicity I reuse the same lambda for both GET and POST methods
resource "aws_api_gateway_integration" "integration_api_gateway_get_conversation" {
  rest_api_id             = aws_api_gateway_rest_api.kata_api_to_persona.id
  resource_id             = aws_api_gateway_resource.resource_conversation.id
  http_method             = aws_api_gateway_method.method_conversation_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.kata_lambda_to_bedrock.invoke_arn
}

resource "aws_api_gateway_integration" "integration_api_gateway_post_conversation" {
  rest_api_id             = aws_api_gateway_rest_api.kata_api_to_persona.id
  resource_id             = aws_api_gateway_resource.resource_conversation.id
  http_method             = aws_api_gateway_method.method_conversation_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.kata_lambda_to_bedrock.invoke_arn
}

resource "aws_api_gateway_deployment" "gateway_deployment" {
  rest_api_id = aws_api_gateway_rest_api.kata_api_to_persona.id
  depends_on = [
    aws_api_gateway_method.method_conversation_post,
    aws_api_gateway_integration.integration_api_gateway_get_conversation,
    aws_api_gateway_integration.integration_api_gateway_post_conversation
  ]
}

resource "aws_api_gateway_stage" "prod" {
  rest_api_id   = aws_api_gateway_rest_api.kata_api_to_persona.id
  deployment_id = aws_api_gateway_deployment.gateway_deployment.id
  stage_name    = "prod"
}

# Permissions to execute the lambda from the gateway
resource "aws_lambda_permission" "permissions_execute_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.kata_lambda_to_bedrock.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.kata_api_to_persona.execution_arn}/*/*/*"
  depends_on = [
    aws_lambda_function.kata_lambda_to_bedrock,
    aws_api_gateway_rest_api.kata_api_to_persona,
    aws_api_gateway_resource.resource_conversation
  ]
}
