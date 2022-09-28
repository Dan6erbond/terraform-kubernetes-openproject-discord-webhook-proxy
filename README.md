# Terraform Kubernetes OpenProject Discord Webhook Proxy Module

This is a Terraform module to deploy [openproject-discord-webhook-proxy](https://github.com/Dan6erbond/openproject-discord-webhook-proxy) to Kubernetes.

## Usage

```tf
module "openproject-discord-webhook-proxy" {
  source               = "Dan6erbond/openproject-discord-webhook-proxy/kubernetes"

  namespace            = "openproject-discord-webhook-proxy"

  container_port       = 5001

  service_type         = "ClusterIP"
  service_port         = 5001

  enable_ingress       = true
  ingress_class        = "nginx"
  ingress_annotations  = {
    "cert-manager.io/cluster-issuer" = var.cluster_issuer_name
  }
  ingress_host = "openproject-discord-webhook-proxy.example.com"

  tls_configuration    = [{
    secret_name = "openproject-discord-webhook-proxy-tls"
    hosts       = ["openproject-discord-webhook-proxy.example.com"]
  }]

  s3_bucket_name       = "openproject-discord-webhook-proxy"
  s3_region            = "local"
  s3_endpoint          = "minio.example.com"
  s3_access_key        = "<access-key>"
  s3_secret_key        = "<secret-key>"
  s3_use_ssl           = true

  webhooks             = [
    {
      name   = "my-webhook"
      url    = "<discord-webhook-url>"
      secret = "<secret>"
    }
  ]

  openproject_base_url = "https://openproject.example.com"
}
```

## Storage

You can configure local storage or S3 storage with this module. S3 storage is recommended, as it allows the proxy to be completely stateless which can enable scaling.

To enable local storage set `enable_local_storage` to `true` and provide a `storage_class` if necessary.

## Ingress

This module supports K8s ingress, and can be enabled with the `enable_ingress` variable. You can also add additional annotations and configure TLS with variables.

## Webhooks

Webhooks are configured as maps, with the same options from openproject-discord-webhook-proxy `config.yaml`. For more information see [here](https://github.com/Dan6erbond/openproject-discord-webhook-proxy#configuration).
