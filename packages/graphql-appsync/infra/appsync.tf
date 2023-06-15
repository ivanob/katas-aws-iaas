resource "aws_appsync_graphql_api" "appsync_kata" {
  name                = "appsync-kata-app"
  authentication_type = "API_KEY"
  schema              = file("schema.graphql")
}

resource "aws_appsync_api_key" "appsync_api_key" {
  api_id = aws_appsync_graphql_api.appsync_kata.id
}

resource "aws_iam_role_policy_attachment" "appsync_invoke_lambda" {
  role       = aws_iam_role.iam_appsync_role.name
  policy_arn = aws_iam_policy.iam_invoke_lambda_policy.arn
}