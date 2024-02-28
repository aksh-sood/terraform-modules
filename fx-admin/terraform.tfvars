region             = "us-east-1"
environment        = "aksh"
vendor             = "baton"
kms_key_arn        = "arn:aws:kms:us-east-1:130759691668:key/1392bbbc-5099-4b24-9956-0899987c1f40"
eks_security_group = "sg-085d41fb88734675c"
public_subnet_ids = [
  "subnet-00f4a043e1b549f95",
  "subnet-0802bd542c08d8cba",
  "subnet-06a094ad607a453c4",
]
private_subnet_ids = [
  "subnet-020605ab594af04ce",
  "subnet-0cb5216b77306070f",
  "subnet-07aac25a954f25117",
]
vpc_id                              = "vpc-03deeeec9786ae012"
activemq_engine_version             = "5.15.16"
activemq_storage_type               = "efs"
activemq_instance_type              = "mq.t2.micro"
activemq_apply_immediately          = true
activemq_auto_minor_version_upgrade = false
activemq_publicly_accessible        = true
activemq_username                   = "admin"
baton_application_namespaces        = []

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

rabbitmq_engine_version             = "3.11.20"
rabbitmq_instance_type              = "mq.m5.large"
rabbitmq_apply_immediately          = true
rabbitmq_auto_minor_version_upgrade = false
rabbitmq_publicly_accessible        = false
rabbitmq_username                   = "master"
rabbitmq_enable_cluster_mode        = false
