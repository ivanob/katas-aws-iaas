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
  
  # target = "integrations/${aws_apigatewayv2_integration.connect_integration.id}"
}

# $disconnect route - triggered when a client disconnects
resource "aws_apigatewayv2_route" "disconnect_route" {
  api_id    = aws_apigatewayv2_api.websocket_api.id
  route_key = "$disconnect"
  
  # target = "integrations/${aws_apigatewayv2_integration.disconnect_integration.id}"
}

# Custom route for game actions (e.g., "move", "join")
resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.websocket_api.id
  route_key = "$default"
  
  # target = "integrations/${aws_apigatewayv2_integration.default_integration.id}"
}

# Integration for $connect (commented out - add your Lambda ARN)
# resource "aws_apigatewayv2_integration" "connect_integration" {
#   api_id           = aws_apigatewayv2_api.websocket_api.id
#   integration_type = "AWS_PROXY"
#   integration_uri  = "arn:aws:lambda:REGION:ACCOUNT_ID:function:connect-handler"
# }

# Integration for $disconnect (commented out - add your Lambda ARN)
# resource "aws_apigatewayv2_integration" "disconnect_integration" {
#   api_id           = aws_apigatewayv2_api.websocket_api.id
#   integration_type = "AWS_PROXY"
#   integration_uri  = "arn:aws:lambda:REGION:ACCOUNT_ID:function:disconnect-handler"
# }

# Integration for $default (commented out - add your Lambda ARN)
# resource "aws_apigatewayv2_integration" "default_integration" {
#   api_id           = aws_apigatewayv2_api.websocket_api.id
#   integration_type = "AWS_PROXY"
#   integration_uri  = "arn:aws:lambda:REGION:ACCOUNT_ID:function:message-handler"
# }

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