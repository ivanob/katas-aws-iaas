# Create the Lambda function
resource "aws_lambda_function" "auth_lambda" {
  filename         = data.archive_file.zip_lambda_auth.output_path # Path to the ZIP file containing the Lambda function code
  function_name    = "auth_lambda_function"
  role             = aws_iam_role.iam_for_lambda_auth.arn
  handler          = "lambda-auth.handler" # Change this to match the handler function in your Lambda code
  runtime          = "nodejs16.x" # Change this to match the runtime of your Lambda code
    source_code_hash = data.archive_file.zip_lambda_auth.output_base64sha256
}

data "archive_file" "zip_lambda_auth" {
  type        = "zip"
  source_file = "../dist/lambda-auth.js"
  output_path = "../dist/lambda-auth.zip"
}

resource "aws_iam_role" "iam_for_lambda_auth" {
  name               = "lambda_role_auth"
  assume_role_policy = data.aws_iam_policy_document.policy_execute_lambda_auth.json
  managed_policy_arns = [
    aws_iam_policy.lambda_policy_for_cloudwatch.arn # Permissions to write logs
  ]
}

data "aws_iam_policy_document" "policy_execute_lambda_auth" {
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
