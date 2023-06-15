# =============
# --- Roles ---
# -------------

# Lambda role

data "aws_iam_policy_document" "iam_lambda_role_document" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "iam_lambda_role" {
  name               = "iam_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.iam_lambda_role_document.json
}

# Policy for DynamoDB
resource "aws_iam_role_policy" "policy_call_dynamodb" {
  name = "policy_call_dynamodb"
  role = "${aws_iam_role.iam_appsync_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_dynamodb_table.database-appsync-users.arn}"
      ]
    }
  ]
}
EOF
}

# ================
# --- Policies ---
# ----------------
# Invoke Lambda policy

data "aws_iam_policy_document" "iam_invoke_lambda_policy_document" {
  statement {
    actions   = ["lambda:InvokeFunction"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "iam_invoke_lambda_policy" {
  name   = "iam_invoke_lambda_policy"
  policy = data.aws_iam_policy_document.iam_invoke_lambda_policy_document.json
}

# Appsync role

data "aws_iam_policy_document" "iam_appsync_role_document" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["appsync.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "iam_appsync_role" {
  name               = "iam_appsync_role"
  assume_role_policy = data.aws_iam_policy_document.iam_appsync_role_document.json
}