terraform {
  backend "s3" {
    bucket = "automation-state-terraform"
    key    = "terraform-state"
    region = "us-east-1"
  }
}