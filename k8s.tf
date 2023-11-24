resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = var.service_name
  }
}

resource "helm_release" "jenkins" {
  name       = var.service_name
  repository = "https://charts.jenkins.io/"
  chart      = var.service_name
  namespace  = var.service_name
  values = [
    "${file("values.yaml")}"
  ]
}