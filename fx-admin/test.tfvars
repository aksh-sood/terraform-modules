region             = "us-west-2"
environment        = "aksh"
vendor             = "baton"
kms_key_arn        = "arn:aws:kms:us-west-2:130759691668:key/fa72c934-3bb5-4b27-bdab-3713ef0b4ee1"
eks_security_group = "sg-0cef8319b5e39eb4d"
public_subnet_ids = [
  "subnet-0e0ab77e57f337475",
  "subnet-04f77ecb3d0a30544",
  "subnet-0103a1731403b7c98",
]
private_subnet_ids = [
  "subnet-04cc1f5be5b9c36e8",
  "subnet-0ff074c0009653892",
  "subnet-0bc4b2f4f096b55da",
]
vpc_id                              = "vpc-0cc4119089691d51e"
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
domain_name ="batonsystem.com"