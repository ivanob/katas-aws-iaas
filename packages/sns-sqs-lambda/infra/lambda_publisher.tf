# This block is the definiton of the lambda itself
resource "aws_lambda_function" "lambda_publisher" {
  filename         = data.archive_file.zip_publisher.output_path
  function_name    = "handler_weather_publisher"
  handler          = "lambda-publisher.handler"
  runtime          = "nodejs16.x"
  role             = aws_iam_role.iam_for_lambda.arn
  memory_size      = 128
  timeout          = 5
  source_code_hash = data.archive_file.zip_publisher.output_base64sha256
}

# I create a cloudwatch log group to allow logging on this lambda
resource "aws_cloudwatch_log_group" "function_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_publisher.function_name}"
  retention_in_days = 3
  lifecycle {
    prevent_destroy = false
  }
}

# This data block packs the lambda source code into a zip
data "archive_file" "zip_publisher" {
  type        = "zip"
  source_file = "../dist/lambda-publisher.js"
  output_path = "../dist/lambda-publisher.zip"
}

# Permissions to write on the SNS queue
resource "aws_iam_policy" "lambda_policy_for_sns" {
  name_prefix = "lambda_publish_sns_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sns:Publish"
        ]
        Effect = "Allow"
        Resource = aws_sns_topic.topic_weather.arn
      }
    ]
  })
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "lambda_role_publisher"
  assume_role_policy = data.aws_iam_policy_document.policy_execute_lambda.json
  managed_policy_arns = [
    aws_iam_policy.lambda_policy_for_sns.arn,
    aws_iam_policy.lambda_policy_for_cloudwatch.arn,
  ]
}