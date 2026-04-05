# The CloudFront URL that is used to access the website
output "cloudfront_url" {
  description = "The URL of the CloudFront distribution"
  value       = "https://${aws_cloudfront_distribution.website_cdn.domain_name}"
}

# The Name of the S3 bucket that was created
output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.website_bucket.id
}
