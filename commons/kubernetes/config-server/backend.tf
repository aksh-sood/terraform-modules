terraform {
  backend "s3" {
    bucket = "automation-state-terraform"
    key    = "config-server/terraform-state"
    region = "us-east-1"
  }
}
