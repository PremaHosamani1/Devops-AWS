# Create an S3 bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket        = "my-bucket-2025-new4"
  force_destroy = true
  region        = "us-east-1"
  tags = {
    Environment = "prod"
    Name        = "My bucket"
  }

}
output "aws_s3_bucket_name" {
  value = aws_s3_bucket.my_bucket.arn
}