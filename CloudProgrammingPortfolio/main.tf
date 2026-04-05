# Setting up the AWS provider and region
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ----------------------- S3 BUCKET -----------------------
# Creating the S3 bucket
resource "aws_s3_bucket" "website_bucket" {
  bucket = var.bucket_name
}

# Blocking public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "website_bucket_pab" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Uploading the HTML file to the S3 bucket
resource "aws_s3_object" "index.html" {
  bucket       = aws_s3_bucket.website_bucket.id
  key          = "index.html"
  source       = var.index_html_path
  content_type = "text/html"
}

# ----------------------- CloudFront OAC -----------------------
# Creating an OAC for CloudFront to access it privately
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "website-oac"
  description                       = "OAC for S3 website bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"

}


# ----------------------- CloudFront Distribution -----------------------
# Creating the CloudFront distribution (CDN)
resource "aws_cloudfront_distribution" "website_cdn" {
  enabled             = true
  default_root_object = "index.html"
  comment             = "CloudFront distribution for task 1's website"

  # Guiding CloudFront to the S3 bucket as the origin
  origin {
    domain_name              = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id                = "s3-website-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  # Cache settings
  default_cache_behavior {
    target_origin_id       = "s3-website-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  # Allowing global access to the distribution 
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Using the default SSL certificate
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# ----------------------- S3 Bucket Policy -----------------------
