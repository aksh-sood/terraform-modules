locals {

  domain_name = ""
  config_server = {
    namespace       = "config-server"
    customer        = "config-server"
    docker_registry = "150399859526.dkr.ecr.us-west-2.amazonaws.com"
    istio_injection = false
    enable_gateway  = false
    common_env      = {}
    service = {
      name            = "config-server"
      env             = {}
      target_port     = 8888
      port            = 8888
      url_prefix      = ""
      image_tag       = "3.0.56"
      health_endpoint = ""
      volumeMounts = {
        volumes = [
          {
            name = "ssh-key"
            secret = {
              secretName = "ssh-key"
              readOnly   = true
            }
          }
        ]

        mounts = [{
          mountPath = "/root/.ssh/id_rsa"
          name      = "ssh-key"
          subPath   = "id_rsa"
        }]
      }
    }
  }

}