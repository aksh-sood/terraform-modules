region = "us-east-1"

environment = "malayil"

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

acm_certificate_bucket = "test-certificate-iaac"

acm_certificate = "cert.pem"

acm_certificate_chain = "origin_ca_rsa_root.pem"

acm_private_key = "key.pem"

create_eks = true

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

create_rds                                = true
rds_mysql_version                         = "8.0"
rds_instance_type                         = "db.t4g.large"
rds_master_username                       = "root"
rds_reader_needed                         = true
rds_parameter_group_family                = "aurora-mysql8.0"
rds_enable_performance_insights           = true
rds_performance_insights_retention_period = 7
rds_reader_instance_type                  = "db.t4g.large"
rds_enable_deletion_protection            = false
rds_enable_auto_minor_version_upgrade     = false
rds_enable_event_notifications            = true
rds_ingress_whitelist                     = []
rds_db_cluster_parameter_group_parameters = []
rds_preferred_backup_window               = "07:00-09:00"
rds_publicly_accessible                   = false
rds_db_parameter_group_parameters = [
  {
    name         = "long_query_time"
    value        = "10"
    apply_method = "immediate"
  }
]
rds_enabled_cloudwatch_logs_exports = ["slowquery", "audit", "error"]
rds_ca_cert_identifier              = "rds-ca-rsa2048-g1"
rds_backup_retention_period         = 7

activemq_engine_version      = "5.15.16"
activemq_storage_type        = "efs"
activemq_host_instance_type  = "mq.t2.micro"
apply_immediately            = true
auto_minor_version_upgrade   = false
activemq_publicly_accessible = true
activemq_username            = "admin"
