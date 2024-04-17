locals {
    baton_application_namespaces = var.baton_application_namespaces==[]?[
    {
      namespace       = var.environment
      customer        = "osttra"
      istio_injection = false
      enable_activemq = false
      services = [
        {
          name        = "directory-service"
          target_port = 8080
          url_prefix  = "/directory"
          image_tag   = "1.0.4"
        },
        {
          name        = "normalizer"
          target_port = 8080
          url_prefix  = "/normalizer"
          image_tag   = "2.0.13"
        },
        {
          name        = "notaryservice"
          target_port = 8080
          url_prefix  = "/notary"
          image_tag   = "2.0.4"
        },
        {
          name        = "swiftservice"
          target_port = 8080
          url_prefix  = "/swift"
          image_tag   = "2.0.2"
        }
      ]
    }
  ]:[]
}