resource "aws_sns_topic" "topic_weather" {
  name = "weather-topic"  # Update with your desired SNS topic name
  display_name = "Weather"  # Update with your desired SNS topic display name
}

# I expose the SNS topic ARN so I can use it from the lambda code
output "sns_topic_arn" {
  value = aws_sns_topic.topic_weather.arn
}