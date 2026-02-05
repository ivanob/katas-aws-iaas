# This block is the definiton of the lambda itself
resource "aws_lambda_function" "lambda_handle_game_actions" {
  filename         = data.archive_file.zip_get_artists.output_path
  function_name    = "handler_kata2_lambda_handle_game_actions"
  handler          = "lambda-get-artists.getArtists"
  runtime          = "nodejs20.x"
  role             = module.iam_for_lambda_get_artists.role_arn
  memory_size      = 128
  timeout          = 10
  source_code_hash = data.archive_file.zip_get_artists.output_base64sha256
  environment {
    variables = {
      ENVIRONMENT = "production"
    }
  }
}

# This data block packs the lambda source code into a zip
data "archive_file" "zip_game_actions" {
  type        = "zip"
  source_file = "../dist/lambda-release.js"
  output_path = "../dist/lambda-release"
}

module "common_logging_config_handle_game_actions" {
  source     = "./logging"
  iam_lambda_role_id  = "${module.iam_for_lambda_handle_game_actions.role_id}"
  function_name = "${aws_lambda_function.lambda_handle_game_actions.function_name}"
}
