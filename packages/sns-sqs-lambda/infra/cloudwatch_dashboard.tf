resource "aws_cloudwatch_dashboard" "EC2_Dashboard" {
  dashboard_name = "EC2-Dashboard"
  dashboard_body = <<EOF
    {
    "widgets": [
        { 
            "type": "metric",
            "x": 12,
            "y": 7,
            "width": 12,
            "height": 6,
            "properties": {
                "metrics": [
                [
                    "AWS/Lambda", "Invocations",
                    "FunctionName", "${aws_lambda_function.lambda_publisher.function_name}",
                    "Resource", "${aws_lambda_function.lambda_publisher.function_name}",
                    {
                    "color": "red",
                    "stat": "Sum",
                    "period": 10
                    }
                ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${data.aws_region.current.name}",
                "title": "Invocations"
            }
        }
    ]
    }
EOF
}
