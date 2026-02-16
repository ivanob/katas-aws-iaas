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
  auto_deploy = true

  # access_log_settings {
  #   destination_arn = aws_cloudwatch_log_group.api_gateway_logs.arn
  #   format = jsonencode({
  #     requestId      = "$context.requestId"
  #     ip             = "$context.identity.sourceIp"
  #     requestTime    = "$context.requestTime"
  #     routeKey       = "$context.routeKey"
  #     status         = "$context.status"
  #   })
  # }

  default_route_settings {
    throttling_rate_limit  = 100   # Rate: messages per second
    throttling_burst_limit = 200   # Burst: concurrent messages
    logging_level          = "INFO"
    data_trace_enabled     = true
    detailed_metrics_enabled = true
  }
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

# Create IAM role for API Gateway to write to CloudWatch
resource "aws_iam_role" "api_gateway_cloudwatch_role" {
  name = "kata2-apigateway-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach the managed policy for CloudWatch Logs
resource "aws_iam_role_policy_attachment" "api_gateway_cloudwatch_policy" {
  role       = aws_iam_role.api_gateway_cloudwatch_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

# Set the CloudWatch role in API Gateway account settings (V1 - still needed for V2)
resource "aws_api_gateway_account" "main" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch_role.arn
}