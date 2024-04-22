terraform {
  backend "s3" {
    bucket = "automation-state-terraform"
    key    = "test/aws/terraform-state"
    region = "us-east-1"
  }
}
