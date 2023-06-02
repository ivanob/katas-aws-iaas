

# Permissions to execute the lambda from the gateway
resource "aws_lambda_permission" "permissions_execute_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_url_signer.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.gateway_to_s3.execution_arn}/*/*/*"
  depends_on = [
    "aws_lambda_function.lambda_url_signer",
    "aws_api_gateway_rest_api.gateway_to_s3",
    "aws_api_gateway_resource.Item"
  ]
}