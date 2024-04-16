resource "kubernetes_namespace_v1" "data_import" {
  metadata {
    name = "utility"
  }
}

resource "kubernetes_config_map" "sql_dump" {
  metadata {
    name      = "directory-service-dump"
    namespace = kubernetes_namespace_v1.data_import.metadata[0].name
  }

  data = {
    "directory-service.sql" = "${templatefile("${path.module}/directory-service.sql", {
      database = var.database_name
    })}"
  }
}

resource "kubernetes_job_v1" "demo" {
  metadata {
    name      = "directory-service-data-import"
    namespace = kubernetes_namespace_v1.data_import.metadata[0].name
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
          name    = "alpine"
          image   = "alpine:3.19.1"
          command = ["sh", "-c", "apk add mysql-client && mysql -h $HOSTNAME -u $USERNAME -P 3306 -p$PASSWORD --force < /etc/config/directory-service.sql"]
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
            value = var.username
          }
          env {
            name  = "PASSWORD"
            value = var.password
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