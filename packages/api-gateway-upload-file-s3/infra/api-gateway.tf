# Define the API Gateway resource
resource "aws_api_gateway_rest_api" "gateway_to_s3" {
  name        = var.s3_bucket_name
  description = "Example API Gateway proxy to s3"
}

# Define resources and methods

resource "aws_api_gateway_resource" "Item" {
  rest_api_id = aws_api_gateway_rest_api.gateway_to_s3.id
  parent_id   = aws_api_gateway_rest_api.gateway_to_s3.root_resource_id
  path_part   = "{item+}"
}

resource "aws_api_gateway_method" "method_get_presigned_url" {
  rest_api_id   = aws_api_gateway_rest_api.gateway_to_s3.id
  resource_id   = aws_api_gateway_resource.Item.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration_api_gateway_get_presigned_url_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.gateway_to_s3.id
  resource_id             = aws_api_gateway_resource.Item.id
  http_method             = aws_api_gateway_method.method_get_presigned_url.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_url_signer.invoke_arn
}

# I create a prod stage so the gateway can be called from outside
resource "aws_api_gateway_deployment" "gateway_deployment" {
  rest_api_id = aws_api_gateway_rest_api.gateway_to_s3.id
  stage_name  = "prod"
  depends_on = [
    aws_api_gateway_method.method_get_presigned_url,
    aws_api_gateway_integration.integration_api_gateway_get_presigned_url_lambda
  ]
}