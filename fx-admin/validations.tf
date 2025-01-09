
resource "null_resource" "domain_validation" {
  lifecycle {
    precondition {
      condition     = var.domain_name != "" && var.domain_name != null
      error_message = "Provide domain_name"
    }
  }
}

resource "null_resource" "loadbalacer_url_validation" {
  lifecycle {
    precondition {
      condition = var.create_dns_records ? (
        var.external_loadbalancer_url != "" && var.external_loadbalancer_url != null
      ) : true
      error_message = "Provide  external loadbalancer url or disable create_dns_records"
    }
  }
}

resource "null_resource" "directory_service_data_import_validation" {
  lifecycle {
    precondition {
      condition = var.import_directory_service_db ? (
        var.directory_service_data_s3_bucket_name != "" && var.directory_service_data_s3_bucket_name != null &&
        var.directory_service_data_s3_bucket_path != "" && var.directory_service_data_s3_bucket_path != null
      ) : true
      error_message = "Provide directory_service_data_s3_bucket_name and directory_service_data_s3_bucket_prefix"
    }
  }
}

resource "null_resource" "rds_data_source_validation" {
  lifecycle {
    precondition {
      condition = var.import_directory_service_db ? (
        var.rds_config.snapshot_identifier == null || var.rds_config.snapshot_identifier == ""

      ) : true
      error_message = "import_directory_service_db cannot be true if rds_config.snapshot_identifier is provided"
    }
  }
}

resource "null_resource" "rds_dr_validation" {
  lifecycle {
    precondition {
      condition = var.setup_dr && var.is_dr ? (
        var.global_rds_identifier != "" && var.global_rds_identifier != null &&
        var.primary_region != "" && var.primary_region != null
      ) : true
      error_message = "Provide correct value for global_rds_identifier, primary_region"
    }
  }
}

resource "null_resource" "activemq_dr_validation" {
  lifecycle {
    precondition {
      condition = var.setup_dr && var.is_dr ? (
        var.primary_activemq_broker_arn != "" && var.primary_activemq_broker_arn != null &&
        var.primary_region != "" && var.primary_region != null &&
        var.activemq_replica_user_password != "" && var.activemq_replica_user_password != null
      ) : true
      error_message = "Provide correct value for global_rds_identifier, primary_region"
    }
  }
}

resource "null_resource" "s3_dr_validation" {
  lifecycle {
    precondition {
      condition = var.setup_dr && var.is_dr ? (
        var.primary_kms_key_arn != "" && var.primary_kms_key_arn != null
      ) : true
      error_message = "Provide correct value for primary_kms_key_arn"
    }
  }
}
