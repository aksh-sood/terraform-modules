terraform {
  backend "s3" {
    bucket = "automate-terraform-state-durga"
    key    = "durga/k8"
    region = "us-east-1"
  }
}
