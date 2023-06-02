# Create the S3 bucket
resource "aws_s3_bucket" "gateway_to_s3" {
  bucket = "gateway-to-s3"

  tags = {
    Name        = "gateway_to_s3_bucket"
    Environment = "Dev"
  }
  
  cors_rule {
    allowed_origins = ["*"]  # Specifies the list of allowed origins (domains) that 
    # are allowed to make requests to the S3 bucket. You can use ["*"] to allow requests
    #  from any domain, or you can provide specific domains.
    allowed_methods = ["GET", "PUT"] # Specifies the HTTP methods that are allowed 
    # for cross-origin requests
    allowed_headers = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000 # Specifies the maximum time, in seconds, that the browser 
    # can cache the response for a preflight request
  }
}

resource "aws_s3_bucket_object" "example_object" {
  bucket = aws_s3_bucket.gateway_to_s3.id
  key    = "ponhia.jpeg"
  source = "../ponhia.jpeg"
}
