

# Create the Lambda function
resource "aws_lambda_function" "lambda_subscriber1" {
  filename         = data.archive_file.zip_subscriber.output_path
  function_name    = "handler_weather_subscriber1"
  handler          = "lambda-subscriber.handler"
  runtime          = "nodejs16.x"
  role             = aws_iam_role.iam_for_lambda_subs.arn
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
data "aws_iam_policy_document" "policy_execute_lambda_subscriber" {
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

resource "aws_iam_role" "iam_for_lambda_subs" {
  name               = "lambda_role_subscriber"
  assume_role_policy = data.aws_iam_policy_document.policy_execute_lambda_subscriber.json
  managed_policy_arns = [
    aws_iam_policy.aws_lambda_policy_interact_sqs.arn
  ]
}

# Bind subscriber lambda the SQS queue
resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  event_source_arn = "${aws_sqs_queue.queue_1.arn}"
  enabled          = true
  function_name    = "${aws_lambda_function.lambda_subscriber1.function_name}"
  batch_size       = 1
}

# Create an IAM policy for the Lambda function to interact with SQS
resource "aws_iam_policy" "aws_lambda_policy_interact_sqs" {
  name_prefix = "example"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Effect   = "Allow"
        Resource = aws_sqs_queue.queue_1.arn
      }
    ]
  })
}
