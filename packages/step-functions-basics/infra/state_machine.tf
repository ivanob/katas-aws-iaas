resource "aws_sfn_state_machine" "example_state_machine" {
  name       = "ExampleStateMachine"
  role_arn   = aws_iam_role.state_machine_role.arn
  definition = <<EOF
{
  "Comment": "A Step Functions state machine example with 3 states",
  "StartAt": "PathInitial",
  "States": {
    "PathInitial": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.start",
          "StringEquals": "Path1",
          "Next": "RandomLambda"
        },
        {
          "Variable": "$.start",
          "StringEquals": "Path2",
          "Next": "Path2"
        }
      ],
      "Default": "RandomLambda"
    },
    "RandomLambda": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.lambda_choice.arn}",
      "Next": "ChoiceState"
    },
    "ChoiceState": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.result",
          "StringEquals": "Option1",
          "Next": "Option1State"
        },
        {
          "Variable": "$.result",
          "StringEquals": "Option2",
          "Next": "Option2State"
        }
      ],
      "Default": "Option1State"
    },
    "Option1State": {
      "Type": "Pass",
      "Result": {
        "result": "input"
      },
      "End": true
    },
    "Option2State": {
      "Type": "Pass",
      "Result": {
        "result": "input"
      },
      "End": true
    },
    "Path2": {
      "Type": "Pass",
      "Result": {
        "result": "input"
      },
      "End": true
    }
  }
}
EOF
}

resource "aws_iam_role" "state_machine_role" {
  name = "ExampleStepFunctionsRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "states.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_invoke_policy" {
  name        = "lambda-invoke-policy"
  description = "Policy to allow invoking Lambda functions"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "lambda:InvokeFunction",
      "Resource": "${aws_lambda_function.lambda_choice.arn}"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "state_machine_policy_attachment" {
  role       = aws_iam_role.state_machine_role.name
  policy_arn = aws_iam_policy.lambda_invoke_policy.arn
}
