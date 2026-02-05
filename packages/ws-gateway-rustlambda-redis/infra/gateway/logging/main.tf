
# I create a cloudwatch log group to allow logging on this lambda
resource "aws_cloudwatch_log_group" "function_log_group" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 3
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_iam_role_policy_attachment" "function_logging_policy_attachment" {
  role       = var.iam_lambda_role_id
  policy_arn = aws_iam_policy.ticketsoft_lambda_logging_policy.arn
}

resource "aws_iam_policy" "ticketsoft_lambda_logging_policy" {
  name   = "ticketsoft-lambda-logging-policy-${var.function_name}-${local.env}"
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