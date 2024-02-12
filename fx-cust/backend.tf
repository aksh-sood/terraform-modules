terraform {
  backend "s3" {
    bucket = "automation-state-terraform"
    key    = "FX-cust/terraform-state"
    region = "us-east-1"
  }
}
