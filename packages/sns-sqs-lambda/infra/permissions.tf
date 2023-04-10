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
        Effect = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Permissions for the Lambda function to interact with SQS
resource "aws_iam_policy" "aws_lambda_policy_interact_sqs" {
  name_prefix = "example"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:sqs:eu-west-1:065454142634:queue_receiver_weather*"
        # Here I could point at a single SQS like this:
        # Resource = "aws_sqs_queue.queue_1.arn"
        # But I will point at all the SQSs I have deployed
      }
    ]
  })
}

# Policy document to execute Lambda
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