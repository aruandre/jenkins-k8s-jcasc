variable "kube_config" {
  type        = string
  description = "Kubernetes config path"
  default     = "~/.kube/config"
}

# Jenkins
variable "jenkins_namespace" {
  type        = string
  description = "Jenkins's namespace name"
  default     = "jenkins"
}

variable "jenkins_chart_version" {
  type        = string
  description = "Jenkins chart version"
  default     = "4.9.1"
}

# Prometheus & Grafana
variable "monitoring_namespace" {
  type        = string
  description = "Monitoring namespace name"
  default     = "monitoring"
}

variable "prometheus_chart_version" {
  type        = string
  description = "Prometheus chart version"
  default     = "25.8.2"
}

variable "grafana_chart_version" {
  type        = string
  description = "Grafana chart version"
  default     = "7.0.17"
}


# Vault
variable "vault_namespace" {
  type        = string
  description = "Vault namespace name"
  default     = "vault"
}

variable "vault_chart_version" {
  type        = string
  description = "Vault chart version"
  default     = "0.27.0"
}

variable "vault_nodePort" {
  type = string
  description = "Node port value for Vault service"
  default = "31500"
}