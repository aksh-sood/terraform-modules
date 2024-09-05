locals {

  env_config_map = merge(var.env_config_map, { for k, v in var.env_config_map_file_path : k => file(v) })

  env_cm = {

    volume = [
      {
        name = kubernetes_config_map.env.metadata[0].name
        configMap = {
          defaultMode = 0444
          name        = kubernetes_config_map.env.metadata[0].name
        }
      }
    ]

    mount = [{
      mountPath = "/home/app/env-cm"
      name      = kubernetes_config_map.env.metadata[0].name
      subPath   = null
      }
    ]
  }
}

