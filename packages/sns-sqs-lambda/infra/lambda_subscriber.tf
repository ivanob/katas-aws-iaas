

# Create the Lambda function
resource "aws_lambda_function" "lambda_subscriber1" {
  filename         = data.archive_file.zip_subscriber.output_path
  function_name    = "handler_weather_subscriber1"
  handler          = "lambda-subscriber.handler"
  runtime          = "nodejs16.x"
  role             = aws_iam_role.iam_for_lambda.arn
  memory_size      = 128
  timeout          = 5
  source_code_hash = data.archive_file.zip_subscriber.output_base64sha256
}

# This data block packs the lambda source code into a zip
data "archive_file" "zip_subscriber" {
  type        = "zip"
  source_file = "../dist/lambda-subscriber.js"
  output_path = "../dist/lambda-subscriber.zip"
}

# Create an IAM role for the Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_lambda_permission" "example" {
  statement_id  = "example-statement-id"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_subscriber1.function_name
  principal     = "sqs.amazonaws.com"

  source_arn = aws_sqs_queue.queue_1.arn
}