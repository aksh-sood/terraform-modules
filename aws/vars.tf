variable "region" {
  description = "Region of aws provider to run on"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment for which the resources are being provisioned"
  type        = string
  default     = "test"
}

variable "vpc_cidr" {
  description = "cidr range for vpc"
  type        = string
  default     = "10.0.0.0/16"
}

variable "cost_tags" {
  description = "Customer Cost and Environment tags for all the resources "
  type        = map(string)
  default = {
    env-type    = "test"
    customer    = "internal"
    cost-center = "overhead"
  }
}

variable "vpc_tags" {
  description = "tags for VPC and any related resources that do not have tags associated with them"
  type        = map(string)
  default     = {}
}

variable "public_subnet_tags" {
  description = "tags for public subnets"
  type        = map(string)
  default     = {}
}

variable "private_subnet_tags" {
  description = "tags for private subnets"
  type        = map(string)
  default     = {}
}

variable "az_count" {
  description = "List of az's code to create subnets in"
  type        = number
  validation {
    condition     = var.az_count > 0 || var.az_count < 6
    error_message = "Number should be greater than 0 and less than 6"
  }
  default = 3
}

variable "enable_nat_gateway" {
  description = "Enable single NAT Gateway for vpc"
  type        = bool
  default     = true
}

variable "public_subnet_cidrs" {
  description = "cidr list of public subnets"
  type        = list(string)
  default     = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]
}

variable "private_subnet_cidrs" {
  description = "cidr list of private subnets"
  type        = list(string)
  default     = ["10.0.96.0/22", "10.0.100.0/22", "10.0.104.0/22"]
}


variable "enable_siem" {
  description = "Whether to enable siem setup and logging"
  default     = true
}

variable "siem_storage_s3_bucket" {
  description = "bucket id for alerts and logging"
  type        = string
  default     = "aes-siem-800161367015-log"
}

variable "create_certificate" {
  description = "Whether to create an AWS ACM certificate or not.If true variables starting with acm area required"
  type        = bool
  default     = true
}

variable "acm_certificate_bucket" {
  description = "Bucket name of acm certificate data"
  type        = string
  default     = "baton-domain-certificates"
}

variable "acm_certificate" {
  description = "S3 path to ACM Domain key"
  type        = string
  default     = "batonsystem.com/cloudflare/batonsystem.com.crt"
}

variable "acm_certificate_chain" {
  description = "S3 path to ACM certificate key"
  type        = string
  default     = "batonsystem.com/cloudflare/origin_ca_rsa_root.pem"
}

variable "acm_private_key" {
  description = "S3 path to ACM private key"
  type        = string
  default     = "batonsystem.com/cloudflare/batonsystem.com.key"
}

variable "create_eks" {
  default = true
}

variable "cluster_version" {
  description = "eks cluster verison"
  type        = string
  default     = "1.28"
}

variable "additional_eks_addons" {
  description = "additional addons for EKS cluster"
  type        = list(string)
  default     = []
}

variable "eks_node_groups" {
  description = "configuration of eks managed nodes groups"
  type = object({
    additional_node_inline_policy = optional(string, null)
    additional_node_policies      = optional(list(string), null)
    volume_type                   = string
    volume_size                   = number
    node_groups = list(object({
      name                       = string
      instance_types             = list(string)
      min_size                   = number
      max_size                   = number
      labels                     = optional(map(string), {})
      additional_security_groups = optional(list(string), [])
      tags                       = optional(map(string), {})
    }))
  })

  default = {

    additional_node_inline_policy = null
    additional_node_policies      = null
    volume_type                   = "gp3"
    volume_size                   = 20

    node_groups = [{
      name = "node1"

      instance_types = ["m5.large"]

      min_size = 1
      max_size = 1

      additional_security_groups = []

      tags = {}
      }

    ]

  }
}

variable "subscribe_security_hub" {
  description = "Wheather to subscribe security hub or not"
  type        = bool
  default     = false
}

variable "security_hub_standards" {
  description = "List security hub standards enabled"
  type        = list(string)
  default = [
    "aws-foundational-security-best-practices/v/1.0.0",
    "cis-aws-foundations-benchmark/v/1.4.0",
    "pci-dss/v/3.2.1",
    "nist-800-53/v/5.0.0"
  ]
}

variable "disabled_security_hub_controls" {
  description = "security hub controls that are disabled for all standards with control id and reason"
  type        = map(map(string))
  default = {
    "aws-foundational-security-best-practices/v/1.0.0" = {
      "AutoScaling.6"    = "Not applicable to us because of our deployment model"
      "CloudFormation.1" = "CloudFormation stacks should be integrated with Simple Notification Service (SNS)"
      "CloudTrail.5"     = "Using SIEM instead"
      "EC2.9"            = "Only the bare necessary machines are exposed"
      "EC2.10"           = "Using SIEM instead"
      "EC2.17"           = "EKS nodes and VPN instances need multiple ENIs"
      "EC2.18"           = "Need 443 and 80 for exposing the application"
      "ECR.3"            = "Need to retain the images"
      "IAM.2"            = "Only one Deployment user"
      "IAM.6"            = "Do not use sub account root account. Main root account has MFA enabled"
      "RDS.6"            = "Alternative compensating controls in place"
      "RDS.13"           = "We need to keep updates manual, automatic updates may break something"
      "S3.11"            = "Already covered in the cloudtrail logs"
      "SNS.2"            = "Alternative compensating controls in place"
      "SSM.1"            = "We do not plan on using System Manager"
      "SSM.3"            = "We do not plan on using System Manager"
      "SecretsManager.1" = "In Baton, we use SecretsManager to store application secrets which includes credentials of external portals, items deployed in K8s clusters etc along with the credentials of the AWS resource. Hence, it's not possible to automatically to rotate the secrets stored in SecretsManager within the scope of AWS"
      "SecretsManager.4" = "In Baton, we use SecretsManager to store application secrets which includes credentials of external portals, items deployed in K8s clusters etc along with the credentials of the AWS resource. Hence, it's not possible to automatically to rotate the secrets stored in SecretsManager within the scope of AWS"
    }
    "cis-aws-foundations-benchmark/v/1.4.0" = {
      "3.3" = "We are already doing that."
      "1.5" = "Baton does not use root on linked accounts"
      "1.6" = "Baton does not use root on linked accounts"
      "3.4" = "Using SIEM instead"
      "3.6" = "Alternative compensating controls in place"
      "3.7" = "Alternative compensating controls in place"
      "5.3" = "Need 443 and 80 for exposing the application"
    }
    "pci-dss/v/3.2.1" = {
      "PCI.IAM.2"        = "Only one Deployment user"
      "PCI.IAM.4"        = "Baton does use root on linked accounts"
      "PCI.IAM.5"        = "Baton does not use root on linked accounts"
      "PCI.IAM.6"        = "The deployment user doesn't have console login enabled"
      "PCI.SSM.1"        = "We don't plan on using System Manager"
      "PCI.SSM.3"        = "We don't plan on using System Manager"
      "PCI.CloudTrail.1" = "Alternative compensating controls in place"
      "PCI.CloudTrail.4" = "Using SIEM instead"
    }
    "nist-800-53/v/5.0.0" = {
      "IAM.9"            = "Using SIEM Instead"
      "AutoScaling.6"    = "Not applicable to us because of our deployment model"
      "CloudFormation.1" = "CloudFormation stacks should be integrated with Simple Notification Service (SNS)"
      "CloudTrail.5"     = "Using SIEM Instead"
      "EC2.9"            = "Only the bare necessary machines are exposed"
      "EC2.10"           = "Using SIEM instead"
      "EC2.17"           = "EKS nodes and VPN instances need multiple ENIs"
      "EC2.18"           = "Need 443 and 80 for exposing the application"
      "ECR.3"            = "Need to retain the images"
      "IAM.2"            = "Only one Deployment user"
      "IAM.5"            = "The deployment user doesn't have console login enabled"
      "IAM.6"            = "Do not use sub account root account. Main root account has MFA enabled"
      "IAM.9"            = "Baton does not use root on linked accounts"
      "IAM.19"           = "The deployment user doesn't have console login enabled"
      "RDS.6"            = "Alternative compensating controls in place"
      "RDS.13"           = "We need to keep updates manual, automatic updates may break something"
      "S3.11"            = "Already covered in the cloudtrail logs"
      "SNS.2"            = "Alternative compensating controls in place"
      "SSM.1"            = "We do not plan on using System Manager"
      "SSM.3"            = "We do not plan on using System Manager"
      "SecretsManager.1" = "In Baton, we use SecretsManager to store application secrets which includes credentials of external portals, items deployed in K8s clusters etc along with the credentials of the AWS resource. Hence, it's not possible to automatically to rotate the secrets stored in SecretsManager within the scope of AWS"
      "SecretsManager.4" = "In Baton, we use SecretsManager to store application secrets which includes credentials of external portals, items deployed in K8s clusters etc along with the credentials of the AWS resource. Hence, it's not possible to automatically to rotate the secrets stored in SecretsManager within the scope of AWS"
    }
  }
}

variable "opensearch_ebs_volume_size" {
  description = "Size of EBS volumes attached to data nodes (in GiB)"
  type        = number
  default     = 20
}

variable "opensearch_instance_type" {
  description = "Instance type of data nodes in the cluster"
  type        = string
  default     = "t3.medium.search"
}

variable "opensearch_master_username" {
  description = "Master Username of Opensearch"
  type        = string
  default     = "master"
}

variable "opensearch_instance_count" {
  description = "Number of instances in the cluster"
  default     = 1
  type        = number
}

variable "opensearch_engine_version" {
  description = "Specify the engine version for the Amazon OpenSearch Service domain"
  default     = "OpenSearch_2.11"
  type        = string
}

variable "create_rds" {
  description = "Create a RDS Cluster"
  default     = true
  type        = bool
}

variable "rds_mysql_version" {
  description = "mysql version for rds aurora"
  type        = string
  default     = "5.7"
}

variable "rds_instance_type" {
  description = "RDS Instance Type"
  type        = string
  default     = "db.t4g.large"
}

variable "rds_master_username" {
  description = "Master Username for RDS"
  type        = string
  default     = "master"
}

variable "rds_reader_needed" {
  description = "Enable reader for RDS"
  type        = bool
  default     = false
}

variable "rds_parameter_group_family" {
  description = "Parameter group Family name. Will be applied to both parameter group and db cluster parameter group"
  type        = string
  default     = "aurora-mysql5.7"
}

variable "rds_enable_performance_insights" {
  description = "Enable RDS Performance Insights"
  type        = bool
  default     = false
}
variable "rds_performance_insights_retention_period" {
  description = "Retention period for performance Insights"
  type        = number
  default     = 7
}

variable "rds_enable_event_notifications" {
  description = "Enable RDS Event Notifications. Notifications through SNS"
  type        = bool
  default     = true
}

variable "rds_reader_instance_type" {
  description = "Instance Type for RDS Reader"
  type        = string
  default     = "db.t4g.large"
}

variable "rds_ingress_whitelist" {
  description = "List Containing SGs or CIDRs to be whitelisted by RDS SG"
  type        = list(string)
  default     = []
}

variable "rds_enable_deletion_protection" {
  description = "Enable Cluster deletion protection"
  type        = bool
  default     = true
}

variable "rds_enable_auto_minor_version_upgrade" {
  description = "Enable Auto Minor Version Upgrade"
  type        = bool
  default     = false
}

variable "rds_db_cluster_parameter_group_parameters" {
  description = "Cluster Parameter Group Parameters"
  type        = list(map(string))
  default     = []
}

variable "rds_preferred_backup_window" {
  description = "Preffered RDS Backup Window. Time in UTC"
  type        = string
  default     = "07:00-09:00"
}

variable "rds_publicly_accessible" {
  description = "Determines whether instances are publicly accessible. Default false"
  type        = bool
  default     = false
}

variable "rds_db_parameter_group_parameters" {
  description = "A list of DB parameters to apply. Note that parameters may differ from a family to an other"
  type        = list(map(string))
  default = [
    {
      name         = "long_query_time"
      value        = "10"
      apply_method = "immediate"
    }
  ]
}

variable "rds_enabled_cloudwatch_logs_exports" {
  description = "Set of log types to export to cloudwatch. If omitted, no logs will be exported. The following log types are supported: audit, error, general, slowquery, postgresql"
  type        = list(string)
  default     = ["slowquery", "audit", "error"]
}

variable "rds_ca_cert_identifier" {
  description = "	The identifier of the CA certificate for the DB instance"
  type        = string
  default     = "rds-ca-rsa2048-g1"
}

variable "rds_backup_retention_period" {
  description = "The days to retain backups for"
  type        = number
  default     = 7
}

variable "activemq_engine_version" {
  type    = string
  default = "5.15.16"

}

variable "activemq_storage_type" {
  type    = string
  default = "efs"

}

variable "activemq_host_instance_type" {
  type    = string
  default = "mq.t2.micro"

}

variable "apply_immediately" {
  type    = bool
  default = true

}

variable "auto_minor_version_upgrade" {
  type    = bool
  default = false

}

variable "activemq_publicly_accessible" {
  type    = bool
  default = true

}

variable "activemq_username" {
  type      = string
  sensitive = true
  default   = "admin"

}

