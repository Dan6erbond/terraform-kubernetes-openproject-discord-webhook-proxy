terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.13.1"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "docker-desktop"
}

module "openproject-discord-webhook-proxy" {
  source  = "Dan6erbond/openproject-discord-webhook-proxy/kubernetes"
  version = "0.2.1"
  # insert the 2 required variables here
  openproject_base_url = "https://openproject.dikurium.ch"
  webhooks = [
    {
      name = "dikurium-all"
      url  = "https://discord.com/api/webhooks/1023927589116575774/nsnpgp-OUtTXosAgEYJ_-fNMHCx9q8VNdaW5g3J9QuICqwXfFZLkSpJ6iJ07LhsJlah5"
    }
  ]

  enable_ingress = true
  ingress_class  = "nginx"
  ingress_annotations = {
    "cert-manager.io/cluster-issuer" = "name"
  }
  tls_configuration = [{
    hosts       = ["myhost.example.com"]
    secret_name = "my-tls"
  }]
}
