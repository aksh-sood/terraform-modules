resource "kubernetes_config_map" "sql_dump" {
  metadata {
    name      = "directory-service-dump"
    namespace = var.namespace
  }

  data = {
    "directory-service.sql" = "${templatefile("${path.module}/directory-service.sql", {
      database = var.database_name
    })}"
  }
}

resource "kubernetes_job_v1" "data_import" {
  metadata {
    name      = "directory-service-data-import"
    namespace = var.namespace
  }
  spec {
    template {
      metadata {}
      spec {
        restart_policy = "Never"

        volume {
          name = "sql-script"

          config_map {
            name = kubernetes_config_map.sql_dump.metadata[0].name

            items {
              key  = "directory-service.sql"
              path = "directory-service.sql"
            }
          }
        }
        container {
          name  = "alpine"
          image = "alpine:3.19.1"
          command = [
            "sh",
            "-c",
            "apk update && apk add mysql-client && mysql -h $HOSTNAME -u $USERNAME -P 3306 -p$PASSWORD --force < /etc/config/directory-service.sql && echo 'IMPORT COMPLETE'"
          ]
          env {
            name  = "HOSTNAME"
            value = var.rds_writer_url
          }
          env {
            name  = "DATABASE"
            value = var.database_name
          }
          env {
            name  = "USERNAME"
            value = var.rds_username
          }
          env {
            name  = "PASSWORD"
            value = var.rds_password
          }
          volume_mount {
            name       = "sql-script"
            mount_path = "/etc/config/"
          }
        }
      }
    }
    backoff_limit = 5
  }
  wait_for_completion = false
  depends_on          = [kubernetes_config_map.sql_dump]
}