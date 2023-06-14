resource "aws_appsync_graphql_api" "appsync_kata" {
  name                = "appsync-kata-app"
  authentication_type = "API_KEY"
  schema              = file("schema.graphql")
}

resource "aws_appsync_api_key" "appsync_api_key" {
  api_id = aws_appsync_graphql_api.appsync_kata.id
}