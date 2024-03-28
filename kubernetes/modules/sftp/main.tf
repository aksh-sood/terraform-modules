resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!*=+?"
  min_special      = 1
  lower            = true
  min_lower        = 1
  numeric          = true
  min_numeric      = 1
  upper            = true
  min_upper        = 1
}

resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_persistent_volume_claim_v1" "this" {
  metadata {
    name = "sftp-data"
    namespace = kubernetes_namespace_v1.this.metadata.0.name
  }
  spec {
    access_modes = ["ReadWriteMany"]
    storage_class_name = var.storage_class_name
    resources {
      requests = {
        storage = "40Gi"
      }
    }
  }
}

resource "kubernetes_service_v1" "this" {
  metadata {
    name = "sftp"
    namespace = kubernetes_namespace_v1.this.metadata.0.name
  }
  spec {
    type = "LoadBalancer"
    selector = {
      app = "sftp"
    }
    port {
      name = "ssh"
      port        = 22
      target_port = 22
    }

  }
}

resource "kubernetes_deployment_v1" "this" {
  
  wait_for_rollout = false

  metadata {
    name = "sftp"
    namespace = kubernetes_namespace_v1.this.metadata.0.name
  }

  spec {
    replicas = 1
    min_ready_seconds = 10 
    selector {
      match_labels = {
        app = "sftp"
      }
    }

    template {
      metadata {
        labels = {
          app = "sftp"
        }
      }

      spec {
        container {
          image = "atmoz/sftp:latest"
          name  = "sftp"
          image_pull_policy = "Always"
          args = [ "${var.sftp_username}:${random_password.password.result}:1001:100:Incoming,Outgoing" ]

          volume_mount {
            mount_path = "home/myuser"
            name = "sftp-data"
          }

          security_context {
            capabilities {
              add = ["SYS_ADMIN"]
            }
          }

          port {
            protocol = "TCP"
            container_port = 22
          }
        }

      security_context  {
        fs_group = 472
      }

    volume {
          name = "sftp-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.this.metadata.0.name
          }
        }
      }
    }
  }
}