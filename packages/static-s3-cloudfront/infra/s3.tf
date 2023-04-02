resource "aws_s3_bucket" "test_static_web" {
  bucket = "ponchik.click"
  acl    = "public-read"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

resource "aws_s3_bucket_acl" "set_acl" {
  bucket = aws_s3_bucket.test_static_web.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "enable_public_access" {
  bucket = aws_s3_bucket.test_static_web.id

  # Disable Block all public access
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

// This declaration uploads the files from the build folder to the s3 bucket
resource "aws_s3_bucket_object" "react_app_files" {
  for_each = fileset("${path.module}/../src/demo-app/build", "**/*")

  bucket = aws_s3_bucket.test_static_web.id
  key = each.value
  source = "${path.module}/../src/demo-app/build/${each.value}"
}

// This is the policy to give access from outside to the s3 objects
resource "aws_s3_bucket_policy" "public_access_policy" {
  bucket = aws_s3_bucket.test_static_web.id

  # Set up bucket policy to allow public read access
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "PublicReadGetObject"
        Effect = "Allow"
        Principal = "*"
        Action = ["s3:*"]
        Resource = ["${aws_s3_bucket.test_static_web.arn}/*"]
      }
    ]
  })
}