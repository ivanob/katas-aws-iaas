# This block is the definiton of the lambda itself
resource "aws_lambda_function" "lambda_api_welcomer" {
  filename         = data.archive_file.zip.output_path
  function_name    = "handler_welcomer"
  handler          = "lambda-welcomer.handler"
  runtime          = "nodejs16.x"
  role             = aws_iam_role.iam_for_lambda.arn
  memory_size      = 128
  timeout          = 5
  source_code_hash = data.archive_file.zip.output_base64sha256
}

# This data block packs the lambda source code into a zip
data "archive_file" "zip" {
  type        = "zip"
  source_file = "../dist/lambda-welcomer.js"
  output_path = "../dist/lambda-welcomer.zip"
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "lambda_role_scraper"
  assume_role_policy = data.aws_iam_policy_document.policy_execute_lambda_welcomer.json
}

data "aws_iam_policy_document" "policy_execute_lambda_welcomer" {
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