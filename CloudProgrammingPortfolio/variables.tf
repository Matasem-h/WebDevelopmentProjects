# Tells Terraform which AWS region to deploy to
variable "aws_region" {
  description = "AWS region for the S3 bucket"
  type        = string
  default     = "eu-central-1"
}

# The name of the S3 bucket, it must be unique worldwide
variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
  default     = "cloud-programming-task1-website"
}

# Tells Terraform where to find the index.html file
variable "index_html_path" {
  description = "Local path to the index.html file"
  type        = string
  default     = "./index.html"
}
