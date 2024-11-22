terraform {
  backend "s3" {
    bucket = "baton-central-terraform-state"
    key    = "DR/FX-admin/terraform-state"
    region = "us-west-2"
  }
}
