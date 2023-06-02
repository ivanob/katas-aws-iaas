# This block is the definiton of the lambda itself
resource "aws_lambda_function" "lambda_url_signer" {
  filename         = data.archive_file.zip.output_path
  function_name    = "handler_url_signer"
  handler          = "lambda-url-signer.handler"
  runtime          = "nodejs16.x"
  role             = aws_iam_role.iam_for_lambda_signer.arn
  memory_size      = 128
  timeout          = 5
  source_code_hash = data.archive_file.zip.output_base64sha256
  environment {
    variables = {
      ALLOWED_ORIGIN = "*" #This variable is put in the env vars and can be used in the lambda via process.env
      URL_EXPIRATION_SECONDS = "300" #300 seconds that the presigned url is valid
      UPLOAD_BUCKET = var.s3_bucket_name
      # AWS_REGION is populated automatically for free :)
    }
  }
}

# This data block packs the lambda source code into a zip
data "archive_file" "zip" {
  type        = "zip"
  source_file = "../dist/lambda-url-signer.js"
  output_path = "../dist/lambda-url-signer.zip"
}

data "aws_iam_policy_document" "policy_execute_lambda_url_signer" {
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

resource "aws_iam_role" "iam_for_lambda_signer" {
  name               = "lambda_role_presign_url"
  assume_role_policy = data.aws_iam_policy_document.policy_execute_lambda_url_signer.json
  managed_policy_arns = [
    aws_iam_policy.aws_lambda_policy_interact_s3.arn
  ]
}


# Permissions for the Lambda function to interact with S3
# This is important cause if I remove the permission to get objects, it would
# return me a signed URL that does not work and throws a 403 forbidden message:
# check this out: https://medium.com/@lakshmanLD/upload-file-to-s3-using-lambda-the-pre-signed-url-way-158f074cda6c
resource "aws_iam_policy" "aws_lambda_policy_interact_s3" {
  name_prefix = "example"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${aws_s3_bucket.gateway_to_s3.bucket}/*"
      }
    ]
  })
}