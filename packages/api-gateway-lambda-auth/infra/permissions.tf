# Permissions to write logs in cloudwatch
resource "aws_iam_policy" "lambda_policy_for_cloudwatch" {
  name_prefix = "lambda_publish_cloudwatch_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}