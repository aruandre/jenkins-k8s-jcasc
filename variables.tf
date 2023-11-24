variable "kube_config" {
  type        = string
  description = "Kubernetes config path"
  default     = "~/.kube/config"
}

variable "service_name" {
  type        = string
  description = "Name of the service"
  default     = "jenkins"
}