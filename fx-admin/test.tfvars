region             = "us-east-1"
environment        = "aksh2"
vendor             = "baton"
kms_key_arn        = "arn:aws:kms:us-east-1:130759691668:key/3d905d17-67f8-4ef3-a262-2eaf30eb4861"
eks_security_group = "sg-013757e0a209c45a2"
public_subnet_ids = [
  "subnet-08cc1bfae6b44ba63",
  "subnet-03cf7b2f4d44e6588",
  "subnet-06bc6f9265c653d92",
]
private_subnet_ids = [
  "subnet-0ce14c6bbf00e1274",
  "subnet-0006af4e4d372804e",
  "subnet-023cde3bb16ef74b0",
]
vpc_id                       = "vpc-03deeeec9786ae012"
activemq_engine_version      = "5.15.16"
activemq_storage_type        = "efs"
activemq_host_instance_type  = "mq.t2.micro"
apply_immediately            = true
auto_minor_version_upgrade   = false
activemq_publicly_accessible = true
activemq_username            = "admin"
baton_application_namespaces = []

rds_mysql_version                         = "8.0"
rds_instance_type                         = "db.t4g.large"
rds_master_username                       = "root"
create_rds_reader                         = true
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