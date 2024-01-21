resource "kubernetes_namespace" "logging" {
  metadata {
    name = var.logging_namespace
  }
}

resource "helm_release" "opensearch" {
  name       = var.opensearch_name
  repository = "https://opensearch-project.github.io/helm-charts"
  chart      = var.opensearch_name
  version    = var.opensearch_chart_version
  namespace  = kubernetes_namespace.logging.id
  timeout    = var.helm_timeout
  values = [
    templatefile("${path.root}/templates/opensearch/opensearch.tpl", {
      nodePort = var.opensearch_nodePort
    })
  ]
}

resource "helm_release" "dashboards" {
  name       = "${var.opensearch_name}-dashboards"
  repository = "https://opensearch-project.github.io/helm-charts"
  chart      = "${var.opensearch_name}-dashboards"
  version    = var.opensearch_dashboards_chart_version
  namespace  = kubernetes_namespace.logging.id
  timeout    = var.helm_timeout
  values = [
    templatefile("${path.root}/templates/opensearch/opensearch.tpl", {
      nodePort = var.opensearch_dashboards_nodePort
    })
  ]
}