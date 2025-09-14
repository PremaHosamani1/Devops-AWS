terraform {
  backend "s3" {
    bucket         = "my-terraform-state-unique123"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}