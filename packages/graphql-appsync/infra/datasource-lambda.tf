resource "aws_lambda_function" "lambda_datasource" {
  filename         = data.archive_file.zip.output_path
  function_name    = "handler_randomizer"
  handler          = "lambda-randomizer.handler"
  runtime          = "nodejs16.x"
  role             = aws_iam_role.iam_for_lambda.arn
  memory_size      = 128
  timeout          = 5
  source_code_hash = data.archive_file.zip.output_base64sha256
}

# This data block packs the lambda source code into a zip
data "archive_file" "zip" {
  type        = "zip"
  source_file = "../dist/lambda-randomizer.js"
  output_path = "../dist/lambda-randomizer.zip"
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "lambda_randomizer"
  assume_role_policy = data.aws_iam_policy_document.policy_execute_lambda_randomizer.json
}

data "aws_iam_policy_document" "policy_execute_lambda_randomizer" {
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