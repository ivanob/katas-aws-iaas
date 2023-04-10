# Create SQS queue number 1
resource "aws_sqs_queue" "queue_1" {
  name = "queue_receiver_weather_1"
}

# Subscribe the SQS queue to the SNS topic
resource "aws_sns_topic_subscription" "subscription_1_to_sns" {
  topic_arn = aws_sns_topic.topic_weather.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.queue_1.arn
  filter_policy = jsonencode({
    city = ["Lisbon", "Portugal"]
  })
  filter_policy_scope = "MessageBody"
}

resource "aws_sqs_queue_policy" "sns_sqs_demo_sqspolicy1" {
  queue_url = aws_sqs_queue.queue_1.id
  policy    = <<EOF
{
  "Version": "2012-10-17",
  "Id": "sns_sqs_policy",
  "Statement": [
    {
      "Sid": "Allow SNS publish to SQS",
      "Effect": "Allow",
      "Principal": {
        "Service": "sns.amazonaws.com"
      },
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.queue_1.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.topic_weather.arn}"
        }
      }
    }
  ]
}
EOF
  depends_on = [
    aws_sns_topic.topic_weather
  ]
}

#################################################

# Create SQS queue number 2
resource "aws_sqs_queue" "queue_2" {
  name = "queue_receiver_weather_2"
}

# Subscribe the SQS queue to the SNS topic
resource "aws_sns_topic_subscription" "subscription_2_to_sns" {
  topic_arn = aws_sns_topic.topic_weather.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.queue_2.arn
  filter_policy = jsonencode({
    city = ["Porto", "Portugal"]
  })
}

resource "aws_sqs_queue_policy" "sns_sqs_demo_sqspolicy2" {
  queue_url = aws_sqs_queue.queue_2.id
  policy    = <<EOF
{
  "Version": "2012-10-17",
  "Id": "sns_sqs_policy",
  "Statement": [
    {
      "Sid": "Allow SNS publish to SQS",
      "Effect": "Allow",
      "Principal": {
        "Service": "sns.amazonaws.com"
      },
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.queue_2.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.topic_weather.arn}"
        }
      }
    }
  ]
}
EOF
  depends_on = [
    aws_sns_topic.topic_weather
  ]
}
