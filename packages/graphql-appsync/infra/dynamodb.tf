resource "aws_dynamodb_table" "database-appsync-users" {
  name         = "kata-appsync-table-users"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  attribute {
    name = "id"
    type = "S"
  }
  tags = {
    Environment = "dev"
  }
}


resource "aws_dynamodb_table_item" "item1" {
  table_name = aws_dynamodb_table.database-appsync-users.name
  hash_key   = aws_dynamodb_table.database-appsync-users.hash_key

  item = <<ITEM
{
  "id": {"S": "123456"},
  "name": {"S": "Joan"},
  "age": {"N": "20"},
  "city": {"S": "Lisbon"}
}
ITEM
}

resource "aws_dynamodb_table_item" "item2" {
  table_name = aws_dynamodb_table.database-appsync-users.name
  hash_key   = aws_dynamodb_table.database-appsync-users.hash_key

  item = <<ITEM
{
  "id": {"S": "123457"},
  "name": {"S": "Anthony"},
  "age": {"N": "35"},
  "city": {"S": "Madrid"}
}
ITEM
}

resource "aws_dynamodb_table_item" "item3" {
  table_name = aws_dynamodb_table.database-appsync-users.name
  hash_key   = aws_dynamodb_table.database-appsync-users.hash_key

  item = <<ITEM
{
  "id": {"S": "123458"},
  "name": {"S": "Peter"},
  "age": {"N": "32"},
  "city": {"S": "London"}
}
ITEM
}
