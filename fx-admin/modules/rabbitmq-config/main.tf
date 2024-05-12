locals {
  vhost = substr(var.vhost, 0, 1) == "/" ? "%2F${substr(var.vhost, 1, length(var.vhost) - 1)}" : var.vhost
}

resource "kubernetes_job_v1" "data_import" {
  metadata {
    name      = "rabbitmq-config"
    namespace = var.namespace
  }
  spec {
    template {
      metadata {}
      spec {
        restart_policy = "Never"
        container {
          name  = "alpine"
          image = "alpine:3.19.1"
          command = [
            "sh",
            "-c",
            "apk update && apk add curl && curl -i -u ${var.rabbitmq_username}:${var.rabbitmq_password} --fail -X PUT ${var.rabbitmq_url}/api/vhosts/${local.vhost} && curl -i -u ${var.rabbitmq_username}:${var.rabbitmq_password} --fail -X PUT -H \"Content-Type:application/json\" -d '{\"type\":\"fanout\",\"durable\":\"true\",\"auto_delete\":\"false\"}' ${var.rabbitmq_url}/api/exchanges/%2F${local.vhost}/${var.exchange}"
          ]
        }
      }
    }
    backoff_limit = 5
  }
  wait_for_completion = false
}