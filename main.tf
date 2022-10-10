terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
  experiments = [module_variable_optional_attrs]
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_persistent_volume_claim" "requests" {
  metadata {
    name      = "openproject-discord-webhook-proxy-requests"
    namespace = kubernetes_namespace.namespace.metadata.0.name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    storage_class_name = var.storage_class
  }
  count = var.enable_local_storage == true ? 1 : 0
}

resource "kubernetes_deployment" "proxy" {
  metadata {
    name      = "openproject-discord-webhook-proxy"
    namespace = kubernetes_namespace.namespace.metadata.0.name
    labels = {
      "app" = "openproject-discord-webhook-proxy"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        "app" = "openproject-discord-webhook-proxy"
      }
    }
    strategy {
      type = "Recreate"
    }
    template {
      metadata {
        labels = {
          "app" = "openproject-discord-webhook-proxy"
        }
      }
      spec {
        init_container {
          name    = "copy-config"
          image   = "busybox"
          command = ["sh", "-c", "cp /tmp/config.yaml /app/config.yaml"]
          volume_mount {
            name       = "config"
            mount_path = "/tmp"
          }
          volume_mount {
            name       = "app"
            mount_path = "/app"
          }
        }
        container {
          image = "dan6erbond/openproject-discord-webhook-proxy"
          name  = "openproject-discord-webhook-proxy"
          port {
            container_port = var.container_port
            name           = "http"
          }
          volume_mount {
            name       = "app"
            mount_path = "/app/config.yaml"
            sub_path   = "config.yaml"
          }
          dynamic "volume_mount" {
            for_each = kubernetes_persistent_volume_claim.requests
            content {
              mount_path = "/app/requests"
              name       = "requests"
            }
          }
        }
        volume {
          name = "app"
          empty_dir {}
        }
        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map.config.metadata.0.name
            items {
              key  = "config"
              path = "config.yaml"
            }
          }
        }
        dynamic "volume" {
          for_each = kubernetes_persistent_volume_claim.requests
          content {
            name = "requests"
            persistent_volume_claim {
              claim_name = volume.value.metadata.0.name
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "proxy" {
  metadata {
    name      = "openproject-discord-webhook-proxy"
    namespace = kubernetes_namespace.namespace.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.proxy.spec.0.template.0.metadata.0.labels.app
    }
    type = var.service_type
    port {
      port        = var.service_port
      target_port = var.container_port
      name        = "http"
    }
  }
}

resource "kubernetes_ingress_v1" "proxy" {
  metadata {
    name      = "openproject-discord-webhook-proxy-ingress"
    namespace = kubernetes_namespace.namespace.metadata.0.name
    annotations = merge({
      "kubernetes.io/ingress.class" = var.ingress_class
    }, var.ingress_annotations)
  }
  spec {
    rule {
      host = var.ingress_host
      http {
        path {
          backend {
            service {
              name = kubernetes_service.proxy.metadata.0.name
              port {
                name = "http"
              }
            }
          }
          path      = var.ingress_path
          path_type = "Prefix"
        }
      }
    }
    dynamic "tls" {
      for_each = var.tls_configuration
      content {
        secret_name = tls.value["secret_name"]
        hosts       = tls.value["hosts"]
      }
    }
  }
  count = var.enable_ingress ? 1 : 0
}

resource "kubernetes_config_map" "config" {
  metadata {
    name      = "openproject-discord-webhook-proxy-config"
    namespace = kubernetes_namespace.namespace.metadata.0.name
  }

  data = {
    config = yamlencode({
      server = {
        host = "0.0.0.0"
        port = var.container_port
      }
      storage = var.s3_bucket_name != "" ? {
        s3 = {
          bucketName = var.s3_bucket_name
          region     = var.s3_region
          endpoint   = var.s3_endpoint
          accessKey  = var.s3_access_key
          secretKey  = var.s3_secret_key
          useSSL     = var.s3_use_ssl
        }
        } : {
        local = {
          path = var.enable_local_storage ? "./requests" : ""
        }
      }
      webhooks = var.webhooks
      openproject = {
        baseUrl = var.openproject_base_url
      }
    })
  }
}
