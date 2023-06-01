# Create the S3 bucket
resource "aws_s3_bucket" "gateway_to_s3" {
  bucket = "gateway-to-s3"

  tags = {
    Name        = "gateway_to_s3_bucket"
    Environment = "Dev"
  }

  cors_rule {
    allowed_origins = ["*"]
    allowed_methods = ["PUT"]
    allowed_headers = ["*"]
    expose_headers  = []
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_object" "example_object" {
  bucket = aws_s3_bucket.gateway_to_s3.id
  key    = "ponhia.jpeg"
  source = "../ponhia.jpeg"
}
