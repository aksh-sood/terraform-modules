region           = "us-west-2"
environment      = "fx-baton-prod"
vendor           = "baton"
domain_name="batonsystems.com"
lambda_packages_s3_bucket = "fx-dev-lambda-packages-oregon"

eks_security_group = "sg-0ffeefdfc3f4d44f6"
public_subnet_ids = [
  "subnet-049115e31580a71fb",
  "subnet-03282c42a176f3466",
  "subnet-03a639f4e3f4f807b",
]
private_subnet_ids = [
  "subnet-0f40c19b9c2194ae7",
  "subnet-06cbd51b3e8b046ce",
  "subnet-046f899e5bc0cdf74",
]
vpc_id = "vpc-0c65f670f2f1f4af1"

activemq_publicly_accessible=true
activemq_engine_version             = "5.18"
activemq_instance_type              = "mq.m5.large"
activemq_apply_immediately          = true
activemq_auto_minor_version_upgrade = true
activemq_username                   = "admin"
# activemq_storage_type               = "efs"
# activemq_whitelist_ips              = []
