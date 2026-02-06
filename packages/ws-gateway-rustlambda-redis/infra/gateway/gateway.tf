# WebSocket API Gateway
resource "aws_apigatewayv2_api" "websocket_api" {
  name                       = "kata2-websocket"
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
}

# $connect route - triggered when a client connects
resource "aws_apigatewayv2_route" "connect_route" {
  api_id    = aws_apigatewayv2_api.websocket_api.id
  route_key = "$connect"
  
  target = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# $disconnect route - triggered when a client disconnects
resource "aws_apigatewayv2_route" "disconnect_route" {
  api_id    = aws_apigatewayv2_api.websocket_api.id
  route_key = "$disconnect"
  
  target = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Custom route for game actions (e.g., "move", "join")
resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.websocket_api.id
  route_key = "$default"
  
  target = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Integration for $connect (commented out - add your Lambda ARN)
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.websocket_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = "${aws_lambda_function.lambda_handle_game_actions.arn}"
}

# Deployment
resource "aws_apigatewayv2_deployment" "websocket_deployment" {
  api_id = aws_apigatewayv2_api.websocket_api.id

  depends_on = [
    aws_apigatewayv2_route.connect_route,
    aws_apigatewayv2_route.disconnect_route,
    aws_apigatewayv2_route.default_route
  ]
}

# Stage
resource "aws_apigatewayv2_stage" "production" {
  api_id      = aws_apigatewayv2_api.websocket_api.id
  name        = "production"
  deployment_id = aws_apigatewayv2_deployment.websocket_deployment.id
}

# Output the WebSocket URL
output "websocket_url" {
  value = "${aws_apigatewayv2_api.websocket_api.api_endpoint}/${aws_apigatewayv2_stage.production.name}"
  description = "WebSocket connection URL"
}

# Give API Gateway permission to invoke the Lambda
resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_handle_game_actions.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.websocket_api.execution_arn}/*/*"
}
