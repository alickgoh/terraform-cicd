# Configure the Terraform backend for remote state storage
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-gohkl" # <-- REPLACE with your S3 bucket name
    key            = "global/s3-website/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "terraform-state-locks" # <-- The DynamoDB table you created
  }
}

# Configure the AWS provider
provider "aws" {
  region = "ap-southeast-1"
}
# Create an S3 bucket to host the website
resource "aws_s3_bucket" "website_bucket" {
  bucket = "my-terraform-website-bucket-gohkl" # Use a globally unique name

  tags = {
    Name        = "My Static Website Bucket - gohkl"
    Environment = "Dev"
  }
}

# Configure the S3 bucket for static website hosting
resource "aws_s3_bucket_website_configuration" "website_configuration" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }
}

# Apply a public read policy to the S3 bucket
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.website_bucket.arn}/*"
      }
    ]
  })
}
# Output the name of the S3 bucket
output "website_bucket_name" {
  value = aws_s3_bucket.website_bucket.id
  description = "The name of the S3 bucket for the website."
}
