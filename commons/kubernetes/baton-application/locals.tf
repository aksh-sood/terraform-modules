locals {

  config_map = merge(var.config_map, { for k, v in var.config_map_file_path : k => file(v) })

  app_cm = {
    volume = [
      {
        name = kubernetes_config_map.app.metadata[0].name
        configMap = {
          defaultMode = 0444
          name        = kubernetes_config_map.app.metadata[0].name
        }
      }
    ]
    mount = [
      {
        mountPath = "/home/app/app-cm"
        name      = kubernetes_config_map.app.metadata[0].name
        subPath   = null
      }
    ]
  }
}
