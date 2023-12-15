variable "kube_config" {
  type        = string
  description = "Kubernetes config path"
  default     = "~/.kube/config"
}

variable "jenkins_namespace" {
  type = string
  description = "Jenkins's namespace name"
  default = "jenkins"
}

variable "monitoring_namespace" {
  type = string
  description = "Monitoring namespace name"
  default = "monitoring"
}

variable "jenkins_chart_version" {
  type = string
  description = "Jenkins chart version"
  default = "4.9.1"
}

variable "prometheus_chart_version" {
  type = string
  description = "Prometheus chart version"
  default = "25.8.2"
}

variable "grafana_chart_version" {
  type = string
  description = "Grafana chart version"
  default = "7.0.17"
}