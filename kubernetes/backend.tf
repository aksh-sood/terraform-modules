terraform {
  backend "s3" {
    bucket = "automation-state-terraform"
    key    = "k8/terraform-state"
    region = "us-east-1"
  }
}