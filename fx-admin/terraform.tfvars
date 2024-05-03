region           = "us-east-1"
k8s_cluster_name = "aksh"
environment      = "fx-baton-test-aksh"
vendor           = "baton"

kms_key_arn =  "arn:aws:kms:us-east-1:130759691668:key/fda8f21d-9968-4b2f-82d7-ff81e63ffae4"

eks_security_group = "sg-07c5d8f049353f1f8"
public_subnet_ids = [
  "subnet-0ab460d851ac1e433",
  "subnet-0f626c3d2a84a8f82",
  "subnet-00e5acc2fa79e55c4",
]
private_subnet_ids = [
  "subnet-00a9ddb4d58ad7650",
  "subnet-0cca9ad1c4382efb2",
  "subnet-07c0de52c9ba48ab7",
]
vpc_id = "vpc-08544128b722af93c"

activemq_engine_version             = "5.15.16"
activemq_storage_type               = "efs"
activemq_instance_type              = "mq.t2.micro"
activemq_apply_immediately          = true
activemq_auto_minor_version_upgrade = false
activemq_username                   = "admin"
activemq_whitelist_ips              = ["223.187.113.120/32", "115.111.183.90/32"]

import_directory_service_db  = true
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
sftp_password = "wb3F!1VtQyit?qZH"

create_dns_records   = false
cloudflare_api_token = "jPvl-qF3HMK1VkY2s6JK7tLx3PeN3uVsbwJDerLl"
loadbalancer_url     = "k8s-istiosys-istioalb-55e6079a17-1297063893.us-east-1.elb.amazonaws.com"
