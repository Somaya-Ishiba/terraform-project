terraform {
  backend "s3" {
    bucket         = "somaya-ishiba-project-bucket"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
