region="us-east-1"
environment        = "application-test"
domain_name        = "batonsystem.com"
secret_name="test"
ssh_secret_key="id_rsa"
config_server = {
    namespace       = "config-server"
    customer        = "baton"
    istio_injection = false
    service = {
      name        = "config-server"
      target_port = 8888
      url_prefix  = "/config"
      image_tag   = "3.0.16"
      health_endpoint = ""
    }
    volumeMounts = {
      volumes = [
        {
          name="ssh-key"
          volumeType="configMap"
          config={
            defaultMode =420
            name = "ssh-key"
          }
        }
      ]  

      mounts = [{
        mountPath = "/root/.ssh/id_rsa"
        name = "ssh-key"
        subPath="id_rsa"
      }
      ]
    }
  }