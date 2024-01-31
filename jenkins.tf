resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = var.jenkins_namespace
  }
}

resource "helm_release" "jenkins" {
  name       = kubernetes_namespace.jenkins.id
  repository = "https://charts.jenkins.io/"
  chart      = kubernetes_namespace.jenkins.id
  version    = var.jenkins_chart_version
  namespace  = kubernetes_namespace.jenkins.id
  values = [
    templatefile("${path.root}/templates/jenkins/jenkins.tpl", {
      nodePort = var.jenkins_nodePort
    })
  ]
}

resource "kubernetes_config_map" "jcasc_jobs" {
  metadata {
    name = "jcasc-jobs"
    labels = {
      jenkins-jenkins-config = "true"
    }
    namespace = kubernetes_namespace.jenkins.id
  }

  data = {
    "jcasc-jobs.yaml" = file("${path.module}/templates/jenkins/jobs.yml")
  }
}

resource "kubernetes_config_map" "jcasc_kubernetes_config" {
  metadata {
    name = "jcasc-kubernetes-config"
    labels = {
      jenkins-jenkins-config = "true"
    }
    namespace = kubernetes_namespace.jenkins.id
  }

  data = {
    "jcasc-kubernetes-config.yaml" = file("${path.module}/templates/jenkins/kubernetes.yml")
  }
}