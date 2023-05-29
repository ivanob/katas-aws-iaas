resource "aws_s3_bucket" "gateway_to_s3" {
  bucket = "gateway-to-s3"

  tags = {
    Name        = "gateway_to_s3_bucket"
    Environment = "Dev"
  }
}