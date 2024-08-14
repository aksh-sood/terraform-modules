region           = "us-east-1"
k8s_cluster_name = "aksh"
environment      = "fx-aksh"
vendor           = "baton"

kms_key_arn = "arn:aws:kms:us-east-1:654654400200:key/6d71af0e-847f-4828-a412-1f32ae6590a5"

eks_security_group = "sg-0ec9391aa0a3ec915"
public_subnet_ids = [
  "subnet-07fd1a58bbda18cc7",
  "subnet-05a6f8b9e4d0a8bd3",
  "subnet-0a1a44f36e0c51f00",
]
private_subnet_ids = [
  "subnet-06b81709a01a147e8",
  "subnet-09909a8a6b475fa72",
  "subnet-0fae77824cac3a9f5",
]
vpc_id = "vpc-0c01476faf9a113a1"

activemq_engine_version             = "5.15.16"
activemq_storage_type               = "efs"
activemq_instance_type              = "mq.t2.micro"
activemq_apply_immediately          = true
activemq_auto_minor_version_upgrade = false
activemq_username                   = "admin"
activemq_whitelist_ips              = ["223.187.113.120/32", "115.111.183.90/32"]

import_directory_service_db  = true
baton_application_namespaces = []

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
rabbitmq_publicly_accessible        = true
rabbitmq_username                   = "master"
rabbitmq_enable_cluster_mode        = false
rabbitmq_virtual_host               = "/nex_osttra"
rabbitmq_exchange                   = "trml_osttra"
rabbitmq_whitelist_ips              = []

domain_name = "batonsystems.com"

user_secrets       = ""
additional_secrets = {}

sftp_host     = "sftp.sftp"
sftp_username = "myuser"
sftp_password = "?4qECWjC9N2DEW73"

create_dns_records   = false
cloudflare_api_token = "jPvl-qF3HMK1VkY2s6JK7tLx3PeN3uVsbwJDerLl"
loadbalancer_url     = "k8s-istiosys-istioalb-55e6079a17-99484393.us-east-1.elb.amazonaws.com"
