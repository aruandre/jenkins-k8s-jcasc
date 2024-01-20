resource "kubernetes_namespace" "opensearch" {
  metadata {
    name = var.opensearch_namespace
  }
}

resource "helm_release" "opensearch" {
  name       = kubernetes_namespace.opensearch.id
  repository = "https://opensearch-project.github.io/helm-charts"
  chart      = kubernetes_namespace.opensearch.id
  version    = var.opensearch_chart_version
  namespace  = kubernetes_namespace.opensearch.id
  timeout    = var.helm_timeout
  values = [
    templatefile("${path.root}/templates/opensearch/opensearch.tpl", {
      nodePort = var.opensearch_nodePort
    })
  ]
}

resource "helm_release" "dashboards" {
  name       = "${kubernetes_namespace.opensearch.id}-dashboards"
  repository = "https://opensearch-project.github.io/helm-charts"
  chart      = "${kubernetes_namespace.opensearch.id}-dashboards"
  version    = var.opensearch_dashboards_chart_version
  namespace  = kubernetes_namespace.opensearch.id
  timeout    = var.helm_timeout
  values = [
    templatefile("${path.root}/templates/opensearch/opensearch.tpl", {
      nodePort = var.opensearch_dashboards_nodePort
    })
  ]
}