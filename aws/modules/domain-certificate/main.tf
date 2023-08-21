# Verifying the certificate data is in correct foramt for streaming and reading
# The metadata of the objects in s3 bucket should be either in text format or json format for the aws_s3_object data resource to read the files.
# Terraform does not provide support to change the metadata options of the object hence a cli approach was taken here
# https://github.com/hashicorp/terraform-provider-aws/issues/5248
# https://github.com/hashicorp/terraform-provider-aws/issues/27697
resource "null_resource" "metadata_update" {
  provisioner "local-exec" {
    command = <<-EOT
     aws s3api copy-object --copy-source ${var.acm_certificate_bucket}/${var.public_key} --key ${var.public_key} --bucket ${var.acm_certificate_bucket} --metadata-directive REPLACE --content-type 'text/plain';
     aws s3api copy-object --copy-source ${var.acm_certificate_bucket}/${var.cert_key} --key ${var.cert_key} --bucket ${var.acm_certificate_bucket} --metadata-directive REPLACE --content-type 'text/plain';
     aws s3api copy-object --copy-source ${var.acm_certificate_bucket}/${var.pem_key} --key ${var.pem_key} --bucket ${var.acm_certificate_bucket} --metadata-directive REPLACE --content-type 'text/plain';
    EOT
  }
}

#This provider is specially configured for the below data sources to read the acm_certificate_bucket 
#when not using the buckets native region
provider "aws" {
  region = "us-east-1"
  alias  = "east"
}

data "aws_s3_object" "private_key" {

  provider = aws.east

  bucket = var.acm_certificate_bucket
  key    = "/${var.public_key}"

  depends_on = [null_resource.metadata_update]
}

data "aws_s3_object" "certificate" {

  provider = aws.east

  bucket = var.acm_certificate_bucket
  key    = "/${var.cert_key}"

  depends_on = [null_resource.metadata_update]
}

data "aws_s3_object" "key_chain" {

  provider = aws.east

  bucket = var.acm_certificate_bucket
  key    = "/${var.pem_key}"

  depends_on = [null_resource.metadata_update]
}

resource "aws_acm_certificate" "acm_cert" {

  private_key       = data.aws_s3_object.private_key.body
  certificate_body  = data.aws_s3_object.certificate.body
  certificate_chain = data.aws_s3_object.key_chain.body

  tags = var.acm_tags
}