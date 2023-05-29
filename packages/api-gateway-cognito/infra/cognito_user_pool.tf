resource "aws_cognito_user_pool" "user_pool" {
  name = "User pool for testing"
  username_configuration {
    case_sensitive = false
  }
}
resource "aws_cognito_user_pool_client" "user_pool_client" {
  name                = "User pool client for testing"
  user_pool_id        = aws_cognito_user_pool.user_pool.id
  explicit_auth_flows = ["ALLOW_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
}