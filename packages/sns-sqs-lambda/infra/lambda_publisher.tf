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

# This data block packs the lambda source code into a zip
data "archive_file" "zip_publisher" {
  type        = "zip"
  source_file = "../dist/lambda-publisher.js"
  output_path = "../dist/lambda-publisher.zip"
}

# Permissions to write on the SNS queue
resource "aws_iam_policy" "lambda_policy" {
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
  assume_role_policy = data.aws_iam_policy_document.policy_execute_lambda_publisher.json
  managed_policy_arns = [
    aws_iam_policy.lambda_policy.arn
  ]
}

data "aws_iam_policy_document" "policy_execute_lambda_publisher" {
  statement {
    sid    = ""
    effect = "Allow"
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}