region = "us-west-2"

environment = "test"

vpc_cidr = "10.0.0.0/16"

public_subnet_tags = {}

private_subnet_tags = {}

cost_tags = {
  env-type    = "test"
  customer    = "internal"
  cost-center = "overhead"
}

vpc_tags = {}

az_count = 3

enable_nat_gateway = true

public_subnet_cidrs = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]

private_subnet_cidrs = ["10.0.96.0/22", "10.0.100.0/22", "10.0.104.0/22"]

siem_storage_s3_bucket = "eks-auto-vpc-flow-logs"

acm_certificate_bucket = "baton-domain-certificates"

acm_certificate = "batonsystems.com/cloudflare/batonsystems.com.key"

acm_certificate_chain = "batonsystems.com/cloudflare/batonsystems.com.crt"

acm_private_key = "batonsystems.com/cloudflare/origin_ca_rsa_root.pem"

create_eks = true

subscribe_security_hub = true

cluster_version = "1.28"

eks_node_groups = {

  additional_node_inline_policy = null
  additional_node_policies      = null
  volume_type                   = "gp3"
  volume_size                   = 20

  node_groups = [{
    name = "node1"

    instance_types = ["m5.large"]

    min_size = 2
    max_size = 2

    additional_security_groups = []

    tags = {}
    }
  ]
}

opensearch_ebs_volume_size = 200
opensearch_instance_type   = "m6g.large.search"
opensearch_instance_count  = 1
opensearch_engine_version  = "OpenSearch_2.11"
