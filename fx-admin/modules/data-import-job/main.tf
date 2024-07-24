terraform {
  required_version = ">= 0.13"

  required_providers {
    kubectl = {
      source                = "gavinbunney/kubectl"
      version               = ">= 1.7.0"
      configuration_aliases = [kubectl.this]
    }
  }
}

resource "kubernetes_manifest" "data_import" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "PersistentVolume"
    "metadata" = {
      "name" = "directory-service-data-import"
    }
    "spec" = {
      "accessModes" = [
        "ReadOnlyMany"
      ]
      "capacity" = {
        "storage" = "100Gi"
      }
      "csi" = {
        "driver" = "s3.csi.aws.com"
        "volumeAttributes" = {
          "bucketName" = "${var.bucket_name}"
        }
        "volumeHandle" = "s3-csi-driver-volume"
      }
      "mountOptions" = [
        "--prefix=${join("/", slice(split("/", var.bucket_path), 0, length(split("/", var.bucket_path)) - 1))}/",
        "region ${var.bucket_region}",
      ]
    }
  }
}

resource "kubectl_manifest" "pvc" {

  provider = kubectl.this

  yaml_body = <<YAML
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: directory-service-data-import
  namespace: ${var.namespace}
spec:
  accessModes:
    - ReadOnlyMany 
  storageClassName: ""
  resources:
    requests:
      storage: 100Gi
  volumeName: ${kubernetes_manifest.data_import.manifest.metadata.name}
  YAML
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

          persistent_volume_claim {
            claim_name = "directory-service-data-import"
          }
        }
        container {
          name  = "alpine"
          image = "alpine:3.19.1"
          command = [
            "sh",
            "-c",
            "apk update && apk add mysql-client && echo 'Importing data' && mysql -h $HOSTNAME -u $USERNAME -P 3306 -p$PASSWORD --force < /directory-data/${split("/", var.bucket_path)[length(split("/", var.bucket_path)) - 1]} && echo 'IMPORT COMPLETE'"
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
            mount_path = "/directory-data"
          }
        }
      }
    }
    backoff_limit = 5
  }
  wait_for_completion = false
}