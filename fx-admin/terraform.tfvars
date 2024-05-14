region           = "us-east-1"
k8s_cluster_name = "aksh3"
environment      = "fx-baton-test-aksh"
vendor           = "baton"

kms_key_arn =  "arn:aws:kms:us-east-1:130759691668:key/79a95e53-a30f-46cc-a7e6-d7386c2a384a"

eks_security_group = "sg-091a559d25242c6b3"
public_subnet_ids = [
  "subnet-0dd6af8fa8d50d91a",
  "subnet-0972119a20c8f6411",
  "subnet-00bf9fa036a7fe135",
]
private_subnet_ids = [
  "subnet-0c8a875d10a18c6a7",
  "subnet-0bebfdb5261469bfa",
  "subnet-06b7d5edf42363c92",
]
vpc_id = "vpc-0cd933dc6b186493e"

activemq_engine_version             = "5.15.16"
activemq_storage_type               = "efs"
activemq_instance_type              = "mq.t2.micro"
activemq_apply_immediately          = true
activemq_auto_minor_version_upgrade = false
activemq_username                   = "admin"
activemq_ingress_whitelist_ips      = ["223.187.113.120/32", "115.111.183.90/32"]
# activemq_egress_whitelist_ips       = ["223.187.113.120/32", "115.111.183.90/32"]

import_directory_service_db  = true
directory_service_data_s3_bucket_name="baton-directory-data-dump"
directory_service_data_s3_bucket_path="central/uat/aksh.sql"
directory_service_data_s3_bucket_region="us-east-1"
# baton_application_namespaces = []

rds_mysql_version                         = "8.0"
rds_instance_type                         = "db.t4g.large"
rds_master_username                       = "root"
create_rds_reader                         = false
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
rds_ca_cert_identifier              = "rds-ca-2019"
rds_backup_retention_period         = 7

rabbitmq_engine_version             = "3.11.20"
rabbitmq_instance_type              = "mq.m5.large"
rabbitmq_apply_immediately          = true
rabbitmq_auto_minor_version_upgrade = false
rabbitmq_username                   = "master"
rabbitmq_enable_cluster_mode        = false
rabbitmq_virtual_host               = "/nex_osttra"
rabbitmq_exchange                   = "trml_osttra"

domain_name = "batonsystems.com"

additional_secrets = {}

sftp_host     = "sftp.sftp"
sftp_username = "myuser"
sftp_password = "a3+jH3!DwLFYZrhz"

create_dns_records   = false
cloudflare_api_token = "jPvl-qF3HMK1VkY2s6JK7tLx3PeN3uVsbwJDerLl"
loadbalancer_url     =  "k8s-istiosys-istioalb-fa9f9871c4-224469423.us-east-1.elb.amazonaws.com"