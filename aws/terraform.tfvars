region = "us-east-1"

environment = "aksh"

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

create_certificate = true

acm_certificate_arn = null

acm_certificate_bucket = "test-certificate-iaac"

acm_certificate = "cloudflare/batonsystems.com.crt"

acm_certificate_chain = "cloudflare/origin_ca_rsa_root.txt"

acm_private_key = "cloudflare/batonsystems.com.key"

create_eks = true

enable_cluster_autoscaler = false

enable_siem = false

enable_client_vpn = false

client_vpn_metadata_bucket_region = "us-west-2"

client_vpn_metadata_bucket_name = "vpn-metadata"

client_vpn_metadata_object_key = "JumpCloud-awsclientvpn-metadata.xml"

enable_client_vpn_split_tunneling = false

client_vpn_access_group_id = "Test User Group"

cluster_version = "1.28"

eks_node_groups = {

  additional_node_inline_policy = null
  additional_node_policies      = null
  volume_type                   = "gp3"
  volume_size                   = 20

  node_groups = [{
    name = "default"

    instance_types = ["m6a.large"]

    min_size = 1
    max_size = 1

    additional_security_groups = []

    tags = {}
    }
  ]
}

opensearch_ebs_volume_size = 200
opensearch_instance_type   = "m6g.large.search"
opensearch_instance_count  = 1
opensearch_engine_version  = "OpenSearch_2.11"