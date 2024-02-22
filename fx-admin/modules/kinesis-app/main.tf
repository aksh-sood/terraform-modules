resource "aws_iam_role" "kinesis_role" {
  name               = "FX_kinesis_app_role_${var.environment}_${var.region}"
  assume_role_policy = <<-EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "kinesisanalytics.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "kinesis_role" {
  for_each = var.kinesis_policies

  role       = aws_iam_role.kinesis_role.name
  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
}

resource "aws_kinesis_analytics_application" "match-trade-kinesis-app" {
  name = "${var.environment}-match-trade"
  code = file("${path.module}/kinesis_app.sql")
  start_application = true
  tags = var.tags


  outputs {
    name = "DESTINATION_SQL_STREAM"
    kinesis_stream {
      resource_arn = var.matched_trades_arn
      role_arn     = aws_iam_role.kinesis_role.arn
    }
    schema {
      record_format_type = "JSON"
    }
  }

  inputs {
    name_prefix = "SOURCE_SQL_STREAM"

    kinesis_stream {
      resource_arn = var.normalized_trades_arn
      role_arn     = aws_iam_role.kinesis_role.arn
    }

    parallelism {
      count = 1
    }

    schema {
      record_columns {
        name     = "type"
        sql_type = "VARCHAR(100)"
        mapping  = "$.type"
      }
      record_columns {
        name     = "trml_version"
        sql_type = "VARCHAR(100)"
        mapping  = "$.trml_version"
      }
      record_columns {
        name     = "primary_node"
        sql_type = "VARCHAR(100)"
        mapping  = "$.primary_node"
      }
      record_columns {
        name     = "secondary_node"
        sql_type = "VARCHAR(100)"
        mapping  = "$.secondary_node"
      }
      record_columns {
        name     = "primary_node_namespace"
        sql_type = "VARCHAR(100)"
        mapping  = "$.primary_node_namespace"
      }
      record_columns {
        name     = "secondary_node_namespace"
        sql_type = "VARCHAR(100)"
        mapping  = "$.secondary_node_namespace"
      }
      record_columns {
        name     = "trade_date"
        sql_type = "VARCHAR(100)"
        mapping  = "$.trade_date"
      }
      record_columns {
        name     = "product"
        sql_type = "VARCHAR(100)"
        mapping  = "$.product"
      }
      record_columns {
        name     = "primary_asset_type"
        sql_type = "VARCHAR(100)"
        mapping  = "$.primary_asset_type"
      }
      record_columns {
        name     = "traded_amount_near"
        sql_type = "DOUBLE"
        mapping  = "$.traded_amount_near"
      }
      record_columns {
        name     = "value_date_near"
        sql_type = "VARCHAR(100)"
        mapping  = "$.value_date_near"
      }
      record_columns {
        name     = "secondary_asset_type"
        sql_type = "VARCHAR(100)"
        mapping  = "$.secondary_asset_type"
      }
      record_columns {
        name     = "record_type"
        sql_type = "VARCHAR(100)"
        mapping  = "$.record_type"
      }
      record_columns {
        name     = "id"
        sql_type = "VARCHAR(100)"
        mapping  = "$.id"
      }
      record_columns {
        name     = "secondary_amount_near"
        sql_type = "DOUBLE"
        mapping  = "$.secondary_amount_near"
      }
      record_columns {
        name     = "process"
        sql_type = "VARCHAR(100)"
        mapping  = "$.process"
      }
      record_columns {
        name     = "trade_group"
        sql_type = "VARCHAR(100)"
        mapping  = "$.trade_group"
      }
      record_columns {
        name     = "trade_id"
        sql_type = "VARCHAR(100)"
        mapping  = "$.trade_id"
      }
      record_columns {
        name     = "matching_time"
        sql_type = "VARCHAR(100)"
        mapping  = "$.matching_time"
      }
      record_columns {
        name     = "normalized_evt_id"
        sql_type = "VARCHAR(100)"
        mapping  = "$.normalized_evt_id"
      }
      record_columns {
        name     = "message_type"
        sql_type = "VARCHAR(100)"
        mapping  = "$.message_type"
      }
      record_columns {
        name     = "md5"
        sql_type = "VARCHAR(100)"
        mapping  = "$.md5"
      }
      record_columns {
        name     = "quote_terms"
        sql_type = "VARCHAR(100)"
        mapping  = "$.quote_terms"
      }
      record_columns {
        name     = "ebnoe"
        sql_type = "VARCHAR(100)"
        mapping  = "$.ebnoe"
      }
      record_columns {
        name     = "rate"
        sql_type = "DOUBLE"
        mapping  = "$.rate"
      }
      record_columns {
        name     = "notes"
        sql_type = "VARCHAR(100)"
        mapping  = "$.notes"
      }
      record_columns {
        name     = "original_trml"
        sql_type = "VARCHAR(4096)"
        mapping  = "$.original_trml"
      }
      record_columns {
        name     = "ticket_num"
        sql_type = "VARCHAR(100)"
        mapping  = "$.ticket_num"
      }
      record_columns {
        name     = "buyer_ticket_num"
        sql_type = "VARCHAR(100)"
        mapping  = "$.buyer_ticket_num"
      }
      record_columns {
        name     = "seller_ticket_num"
        sql_type = "VARCHAR(100)"
        mapping  = "$.seller_ticket_num"
      }
      record_columns {
        name     = "leg"
        sql_type = "VARCHAR(1000)"
        mapping  = "$.leg"
      }

      record_encoding = "UTF-8"

      record_format {
        mapping_parameters {
          json {
            record_row_path = "$"
          }
        }
      }
    }
  }
}