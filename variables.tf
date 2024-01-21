variable "kube_config" {
  type        = string
  description = "Kubernetes config path"
  default     = "~/.kube/config"
}

variable "helm_timeout" {
  type        = number
  description = "Helm release timeout"
  default     = 600
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

# Monitoring
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

# Logging
variable "logging_namespace" {
  type        = string
  description = "Logging namespace name"
  default     = "logging"
}

variable "opensearch_name" {
  type    = string
  default = "opensearch"
}

variable "opensearch_chart_version" {
  type        = string
  description = "OpenSearch chart version"
  default     = "2.17.2"
}

variable "opensearch_dashboards_chart_version" {
  type        = string
  description = "OpenSearch chart version"
  default     = "2.15.1"
}

variable "opensearch_nodePort" {
  type        = number
  description = "Node port for OpenSearch"
  default     = 32700
}

variable "opensearch_dashboards_nodePort" {
  type        = number
  description = "Node port for OpenSearch's Dashboards"
  default     = 32701
}

variable "fluentbit_name" {
  type    = string
  default = "fluent-bit"
}

variable "fluentbit_port" {
  type        = number
  description = "Container port for Fluent-bit"
  default     = 2020
}