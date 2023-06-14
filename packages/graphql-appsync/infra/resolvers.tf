resource "aws_appsync_resolver" "get_user_resolver" {
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


resource "aws_appsync_resolver" "put_user_mutator" {
  api_id = aws_appsync_graphql_api.appsync_kata.id
  type   = "Mutation"
  field  = "putUser"

  data_source = aws_appsync_datasource.datasource-dynamodb.name

  request_template = <<EOF
{
  "version": "2017-02-28",
  "operation": "PutItem",
  "key": {
    "id": $util.dynamodb.toDynamoDBJson($ctx.args.id)
  },
  "attributeValues": $util.dynamodb.toMapValuesJson($ctx.args)
}
EOF

  response_template = "$util.toJson($ctx.result)"
}


resource "aws_appsync_resolver" "get_random_resolver" {
  api_id = aws_appsync_graphql_api.appsync_kata.id
  type   = "Query"
  field  = "getRandom"

  data_source = aws_appsync_datasource.datasource-lambda.name

  request_template = null
  response_template = <<EOF
    $util.toJson($ctx.result)
  EOF
}
