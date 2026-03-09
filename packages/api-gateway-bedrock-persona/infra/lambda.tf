# This block is the definiton of the lambda itself
resource "aws_lambda_function" "kata_lambda_to_bedrock" {
  filename         = data.archive_file.zip.output_path
  function_name    = "handler_conversation"
  handler          = "handler.handler"
  runtime          = "nodejs16.x"
  role             = aws_iam_role.iam_for_lambda.arn
  memory_size      = 128
  timeout          = 10
  source_code_hash = data.archive_file.zip.output_base64sha256
}

# This data block packs the lambda source code into a zip
data "archive_file" "zip" {
  type        = "zip"
  source_file = "../dist/handler.js"
  output_path = "../dist/handler.zip"
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "lambda_role_conversation"
  assume_role_policy = data.aws_iam_policy_document.policy_execute_lambda_conversation.json
}

data "aws_iam_policy_document" "policy_execute_lambda_conversation" {
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