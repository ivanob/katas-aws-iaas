resource "aws_appsync_datasource" "datasource-dynamodb" {
  api_id           = "${aws_appsync_graphql_api.appsync_kata.id}"
  name             = "datasource_dynamodb_users"
  service_role_arn = "${aws_iam_role.iam_appsync_role.arn}"
  type             = "AMAZON_DYNAMODB"

  dynamodb_config {
    table_name = "${aws_dynamodb_table.database-appsync-users.name}"
  }
}

resource "aws_appsync_datasource" "datasource-lambda" {
  api_id           = aws_appsync_graphql_api.appsync_kata.id
  name             = "datasource_lambda_randomizer"
  service_role_arn = "${aws_iam_role.iam_appsync_role.arn}"
  type             = "AWS_LAMBDA"
  lambda_config {
    function_arn = aws_lambda_function.lambda_datasource.arn
  }
}