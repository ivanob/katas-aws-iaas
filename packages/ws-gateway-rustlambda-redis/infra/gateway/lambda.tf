# This block is the definiton of the lambda itself
resource "aws_lambda_function" "lambda_handle_game_actions" {
  filename         = data.archive_file.zip_lambda_handle_game_actions.output_path
  function_name    = "handler_kata2_lambda_handle_game_actions"
  handler          = "main.handler"
  runtime          = "nodejs20.x"
  role             = aws_iam_role.iam_for_lambda_game_actions.arn
  memory_size      = 128
  timeout          = 5
  source_code_hash = data.archive_file.zip_lambda_handle_game_actions.output_base64sha256
  environment {
    variables = {
      ENVIRONMENT = "production"
    }
  }
}

data "archive_file" "zip_lambda_handle_game_actions" {
  type        = "zip"
  source_file = "./dist/lambda-release"
  output_path = "./dist/lambda-release.zip"
}

resource "aws_iam_role" "iam_for_lambda_game_actions" {
  name               = "role_kata2_lambda_handle_game_actions"
  assume_role_policy = data.aws_iam_policy_document.policy_execute_lambda.json
}
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

# module "common_logging_config_handle_game_actions" {
#   source     = "./logging"
#   iam_lambda_role_id  = "${module.iam_for_lambda_handle_game_actions.role_id}"
#   function_name = "${aws_lambda_function.lambda_handle_game_actions.function_name}"
# }
