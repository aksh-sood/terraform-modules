region = "us-east-1"
cost_tags = {
  env-type    = "test"
  customer    = "internal"
  cost-center = "overhead"
}
rds_mysql_version                         = "5.7"
rds_instance_type                         = "db.t4g.large"
rds_master_username                       = "master"
create_rds_reader                         = true
rds_parameter_group_family                = "aurora-mysql5.7"
rds_enable_performance_insights           = true
rds_performance_insights_retention_period = 7
rds_enable_event_notifications            = true
rds_reader_instance_type                  = "db.t4g.large"
rds_ingress_whitelist                     = []
rds_enable_deletion_protection            = false
rds_enable_auto_minor_version_upgrade     = false
rds_db_cluster_parameter_group_parameters = []
rds_preferred_backup_window               = "07:00-09:00"
rds_publicly_accessible                   = false
rds_db_parameter_group_parameters = [
  {
    name         = "long_query_time"
    value        = "10"
    apply_method = "immediate"
}]
rds_enabled_cloudwatch_logs_exports = ["slowquery", "audit", "error"]
rds_ca_cert_identifier              = "rds-ca-rsa2048-g1"
rds_backup_retention_period         = 7

lambda_packages_s3_bucket  = "fx-dev-lambda-packages"
redis_parameter_group_name = "default.redis5.0"
redis_engine_version       = "5.0.5"
redis_node_type            = "cache.t2.micro"
private_subnet_ids = [
  "subnet-0955f6729cbd39000",
  "subnet-02fc88a86d85f70b7",
  "subnet-04eb12797c4ae9ccc",
]
public_subnet_ids = [
  "subnet-019c8fc821767f244",
  "subnet-0cc1fbd7e194abe00",
  "subnet-061403e1a209a55ad",
]
domain_name       = "batonsystem.com"
callback_prefix   = []
logout_prefix     = []
activemq_username = "admin"
# activemq_url                 = "something.com"
# activemq_password            = "somt124"
vpc_id                       = "vpc-0cc38a97d70cfc976"
eks_security_group           = "sg-0cafe24f3d44830ab"
environment                  = "aksh"
kms_key_arn                  = "arn:aws:kms:us-east-1:130759691668:key/9007a482-ad7c-4b47-95c8-9a14720a3e0d"
vendor                       = "baton"
baton_application_namespaces = []
user_secrets                 = ""
additional_secrets           = {}

