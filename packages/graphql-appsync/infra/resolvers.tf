resource "aws_appsync_resolver" "example_resolver" {
  api_id = aws_appsync_graphql_api.appsync_kata.id
  type   = "Query"
  field  = "getUser"

  data_source = aws_appsync_datasource.datasource-dynamodb.name

  request_template = <<EOF
{
  "version": "2017-02-28",
  "operation": "GetItem",
  "key": {
    "id": $util.dynamodb.toDynamoDBJson($ctx.args.id)
  }
}
EOF

  response_template = "$util.toJson($ctx.result)"
}
