region             = "us-east-1"
k8s_cluster_name   = "aksh"
environment        = "fx-aksh"
vendor             = "baton"
kms_key_arn        = ""
eks_security_group = "sg-0b457f8b5e9e06f64"
public_subnet_ids = [
  "subnet-027cf539ee4fec653",
  "subnet-030761f49e0e65470",
  "subnet-08ceb9faebe2892f0",
]
private_subnet_ids = [
  "subnet-06d3bcf175f291d64",
  "subnet-0c84771978a4849f7",
  "subnet-06d59b712c39a378a",
]
vpc_id                              = "vpc-0e25b5870597a61e4"
activemq_engine_version             = "5.15.16"
activemq_storage_type               = "efs"
activemq_instance_type              = "mq.t2.micro"
activemq_apply_immediately          = true
activemq_auto_minor_version_upgrade = false
activemq_publicly_accessible        = true
activemq_username                   = "admin"
import_directory_service_db         = true
baton_application_namespaces        = []

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
rabbitmq_publicly_accessible        = false
rabbitmq_username                   = "master"
rabbitmq_enable_cluster_mode        = false
domain_name                         = "batonsystems.com"
additional_secrets                  = {}
sftp_host                           = "sftp.sftp"
sftp_username                       = "myuser"
sftp_password                       = ""
cloudflare_api_token                = "jPvl-qF3HMK1VkY2s6JK7tLx3PeN3uVsbwJDerLl"
create_dns_records                  = false
loadbalancer_url                    = ""
