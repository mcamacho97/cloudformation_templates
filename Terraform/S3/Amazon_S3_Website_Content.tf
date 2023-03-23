terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-west-2"
}

variable "bucket_name" {
  description = "The bucket name to be created"
  type = string
}

resource "aws_s3_bucket" "s3_bucket_website_content" {
  bucket = var.bucket_name
  website {
    index_document = "index.html"
    error_document = "error.html"
  }
  acl = "public-read"
}

resource "aws_s3_bucket_policy" "s3_bucket_website_content_policy" {
  bucket = var.bucket_name
  policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "s3:GetObject"
          ]
          Effect = "Allow"
          Resource = join("", [aws_s3_bucket.s3_bucket_website_content.arn, "/*"])
          Principal = "*"
        }
      ]
    }
  )
}

output "s3_bucket_secure_url" {
  description = "Name of S3 bucket to hold website content"
  value = join("", ["https://", aws_s3_bucket.s3_bucket_website_content.bucket_domain_name])
}

output "bucket_name" {
  description = "Name of S3 bucket to hold website content"
  value = aws_s3_bucket.s3_bucket_website_content.id
}

output "bucket_endpoint" {
  description = "Endpoint of S3 bucket to hold website content"
  value = aws_s3_bucket.s3_bucket_website_content.bucket_domain_name
}