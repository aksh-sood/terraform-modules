terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 2.7.0"
      configuration_aliases = [aws.east]
    }
  }
}

# Verifying the certificate data is in correct format for streaming and reading
# The metadata of the objects in s3 bucket should be either in text format or json format for the aws_s3_object data resource to read the files.
# Terraform does not provide support to change the metadata options of the object hence a cli approach was taken here
# https://github.com/hashicorp/terraform-provider-aws/issues/5248
# https://github.com/hashicorp/terraform-provider-aws/issues/27697
resource "null_resource" "metadata_update" {
  provisioner "local-exec" {
    command = <<-EOT
     aws s3api copy-object --copy-source ${var.acm_certificate_bucket}/${var.certificate} --key ${var.certificate} --bucket ${var.acm_certificate_bucket} --metadata-directive REPLACE --content-type 'text/plain';
     aws s3api copy-object --copy-source ${var.acm_certificate_bucket}/${var.cert_chain} --key ${var.cert_chain} --bucket ${var.acm_certificate_bucket} --metadata-directive REPLACE --content-type 'text/plain';
     aws s3api copy-object --copy-source ${var.acm_certificate_bucket}/${var.private_key} --key ${var.private_key} --bucket ${var.acm_certificate_bucket} --metadata-directive REPLACE --content-type 'text/plain';
    EOT
  }
}

data "aws_s3_object" "private_key" {

  provider = aws.east

  bucket = var.acm_certificate_bucket
  key    = "/${var.private_key}"

  depends_on = [null_resource.metadata_update]
}

data "aws_s3_object" "certificate" {

  provider = aws.east

  bucket = var.acm_certificate_bucket
  key    = "/${var.certificate}"

  depends_on = [null_resource.metadata_update]
}

data "aws_s3_object" "key_chain" {

  provider = aws.east

  bucket = var.acm_certificate_bucket
  key    = "/${var.cert_chain}"

  depends_on = [null_resource.metadata_update]
}

resource "aws_acm_certificate" "acm_cert" {

  private_key       = data.aws_s3_object.private_key.body
  certificate_body  = data.aws_s3_object.certificate.body
  certificate_chain = data.aws_s3_object.key_chain.body

  tags = var.acm_tags
}