resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.monitoring_namespace
  }
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  version    = var.prometheus_chart_version
  namespace  = kubernetes_namespace.monitoring.id
  values = [
    templatefile("${path.root}/templates/monitoring/prometheus/prometheus.tpl", {
      nodePort = var.prometheus_nodePort
    })
  ]
}

resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = var.grafana_chart_version
  namespace  = kubernetes_namespace.monitoring.id
  values = [
    templatefile("${path.root}/templates/monitoring/grafana/grafana.tpl", {
      nodePort          = var.grafana_nodePort,
      prometheusVersion = var.prometheus_chart_version
    })
  ]
}

resource "kubernetes_config_map" "k8s-dashboard" {
  metadata {
    name      = "k8s-dashboard"
    namespace = kubernetes_namespace.monitoring.id
    labels = {
      grafana_dashboard = "dashboard"
    }
  }
  data = {
    "k8s.json" = "${file("${path.module}/templates/monitoring/grafana/dashboards/k8s.json")}"
  }
}

resource "kubernetes_config_map" "jenkins-dashboard" {
  metadata {
    name      = "jenkins-dashboard"
    namespace = kubernetes_namespace.monitoring.id
    labels = {
      grafana_dashboard = "dashboard"
    }
  }
  data = {
    "jenkins.json" = "${file("${path.module}/templates/monitoring/grafana/dashboards/jenkins.json")}"
  }
}