# This block is the definiton of the lambda itself
resource "aws_lambda_function" "kata_lambda_to_bedrock" {
  filename         = data.archive_file.zip.output_path
  function_name    = "handler_conversation"
  handler          = "handler.handler"
  runtime          = "nodejs20.x"
  role             = aws_iam_role.iam_for_lambda.arn
  memory_size      = 128
  timeout          = 10
  source_code_hash = data.archive_file.zip.output_base64sha256

  environment {
    variables = {
      BEDROCK_MODEL_ID       = var.bedrock_model_id
    }
  }
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

# Permissions to call Bedrock from the lambda
data "aws_iam_policy_document" "lambda_bedrock_invoke" {
  statement {
    sid    = "AllowInvokeSpecificBedrockModel"
    effect = "Allow"

    actions = [
      "bedrock:InvokeModel",
      "bedrock:InvokeModelWithResponseStream"
    ]

    resources = [
      "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/${var.bedrock_model_id}"
    ]
  }
}

resource "aws_iam_policy" "lambda_bedrock_invoke" {
  name   = "lambda-bedrock-invoke-${replace(var.bedrock_model_id, ":", "-")}"
  policy = data.aws_iam_policy_document.lambda_bedrock_invoke.json
}

resource "aws_iam_role_policy_attachment" "lambda_bedrock_invoke" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_bedrock_invoke.arn
}

data "aws_region" "current" {}