resource "aws_appsync_datasource" "datasource-dynamodb" {
  api_id           = "${aws_appsync_graphql_api.appsync_kata.id}"
  name             = "tf_appsync_example"
  service_role_arn = "${aws_iam_role.example.arn}"
  type             = "AMAZON_DYNAMODB"

  dynamodb_config {
    table_name = "${aws_dynamodb_table.database-appsync-users.name}"
  }
}