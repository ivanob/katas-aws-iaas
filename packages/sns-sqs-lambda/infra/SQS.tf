# Create SQS queue number 1
resource "aws_sqs_queue" "queue_1" {
  name = "queue_receiver_weather_1"
}

# Subscribe the SQS queue to the SNS topic
resource "aws_sns_topic_subscription" "subscription_2_to_sns" {
  topic_arn = aws_sns_topic.topic_weather.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.queue_1.arn
}

resource "aws_sqs_queue_policy" "sns_to_allow_sqs1" {
  queue_url = aws_sqs_queue.queue_1.url

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sqs:SendMessage"
        Effect = "Allow"
        Resource = aws_sqs_queue.queue_1.arn

        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.topic_weather.arn
          }
        }
      }
    ]
  })
}

#################################################

# Create SQS queue number 2
resource "aws_sqs_queue" "queue_2" {
  name = "queue_receiver_weather_2"
}

# Subscribe the SQS queue to the SNS topic
resource "aws_sns_topic_subscription" "subscription_1_to_sns" {
  topic_arn = aws_sns_topic.topic_weather.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.queue_2.arn
}

resource "aws_sqs_queue_policy" "sns_to_allow_sqs2" {
  queue_url = aws_sqs_queue.queue_2.url

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sqs:SendMessage"
        Effect = "Allow"
        Resource = aws_sqs_queue.queue_2.arn

        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.topic_weather.arn
          }
        }
      }
    ]
  })
}