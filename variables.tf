variable "namespace" {
  description = "Namespace to deploy the proxy in K8s"
  type        = string
  default     = "openproject-discord-webhook-proxy"
}

variable "enable_local_storage" {
  description = "Enable local storage for request logging"
  type        = bool
  default     = false
}

variable "storage_class" {
  description = "Storage class to use for the local storage PVC"
  type        = string
  default     = ""
}

variable "container_port" {
  description = "The port number for the container"
  type        = number
  default     = 5001
}

variable "service_type" {
  description = "Type of service to configure"
  type        = string
  default     = "ClusterIP"
}

variable "service_port" {
  description = "The port number for the service"
  type        = number
  default     = 5001
}

variable "enable_ingress" {
  description = "If an ingress should be enabled, set this to true"
  type        = bool
  default     = false
}

variable "ingress_class" {
  description = "Class to use for the ingress"
  type        = string
}

variable "ingress_annotations" {
  description = "Ingress annotations, will be merged with the default annotations"
  type        = map(string)
  default     = {}
}

variable "ingress_host" {
  description = "Hostname to use for the ingress"
  type        = string
}

variable "ingress_path" {
  description = "Path to append to the ingress"
  type        = string
  default     = "/"
}

variable "tls_configuration" {
  description = "TLS configuration to add to the ingress"
  type        = list(map(any))
  default     = []
}

variable "s3_bucket_name" {
  description = "S3 bucket name if using S3 for requests logging"
  type        = string
  default     = ""
}

variable "s3_region" {
  description = "S3 region if using S3 or S3-compatible services such as Amazon AWS"
  type        = string
  default     = ""
}

variable "s3_endpoint" {
  description = "S3 endpoint to access"
  type        = string
  default     = ""
}

variable "s3_access_key" {
  description = "S3 access key"
  type        = string
  default     = ""
}

variable "s3_secret_key" {
  description = "S3 secret key"
  type        = string
  default     = ""
}

variable "s3_use_ssl" {
  description = "Use SSL for S3"
  type        = string
  default     = ""
}

variable "webhooks" {
  description = "Webhooks configuration for the proxy"
  type        = list(map(string))
}

variable "openproject_base_url" {
  description = "Base URL of the OpenProject instance, used for building URLs"
  type        = string
}
