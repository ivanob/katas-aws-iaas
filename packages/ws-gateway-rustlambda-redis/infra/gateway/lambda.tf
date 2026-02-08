# This block is the definiton of the lambda itself
resource "aws_lambda_function" "lambda_handle_game_actions" {
  filename         = data.archive_file.zip_lambda_handle_game_actions.output_path
  function_name    = "handler_kata2_lambda_handle_game_actions"
  handler          = "bootstrap" # This is different than in TS, here it is always bootstrap for custom runtimes
  runtime          = "provided.al2023"  # Custom runtime for Rust
  architectures    = ["arm64"]  # (aarch64)
  role             = aws_iam_role.iam_for_lambda_game_actions.arn
  memory_size      = 128
  timeout          = 5
  source_code_hash = data.archive_file.zip_lambda_handle_game_actions.output_base64sha256
  environment {
    variables = {
      ENVIRONMENT = "production",
      REDIS_URL = "redis://${var.redis_endpoint}:6379"
    }
  }
}

data "archive_file" "zip_lambda_handle_game_actions" {
  type        = "zip"
  source_file = "./dist/bootstrap"
  output_path = "./dist/bootstrap.zip"
}

resource "aws_iam_role" "iam_for_lambda_game_actions" {
  name               = "role_kata2_lambda_handle_game_actions"
  assume_role_policy = data.aws_iam_policy_document.policy_execute_lambda.json
}

# Permissions for executing the Lambda (CloudWatch Logs permissions are added in logging/main.tf)
data "aws_iam_policy_document" "policy_execute_lambda" {
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


# I create a cloudwatch log group to allow logging on this lambda
resource "aws_cloudwatch_log_group" "function_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_handle_game_actions.function_name}"
  retention_in_days = 3
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_iam_role_policy_attachment" "function_logging_policy_attachment" {
  role       = aws_iam_role.iam_for_lambda_game_actions.name
  policy_arn = aws_iam_policy.ticketsoft_lambda_logging_policy.arn
}

# 
resource "aws_iam_policy" "ticketsoft_lambda_logging_policy" {
  name   = "ticketsoft-lambda-logging-policy-${aws_lambda_function.lambda_handle_game_actions.function_name}"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Action : [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect : "Allow",
        Resource : "arn:aws:logs:*:*:*"
      }
    ]
  })
}
