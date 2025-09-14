# Create an S3 bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket        = "my-bucket-2025-new2"
  force_destroy = true
  tags = {
    Environment = "prod"
    Name        = "My bucket"
  }

}
output "aws_s3_bucket_name" {
  value = aws_s3_bucket.my_bucket.arn
}