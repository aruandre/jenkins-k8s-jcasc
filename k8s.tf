resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = var.service_name
  }
}

resource "helm_release" "jenkins" {
  name       = var.service_name
  repository = "https://charts.jenkins.io/"
  chart      = var.service_name
  version    = "4.9.1"
  namespace  = var.service_name
  values = [
    "${file("templates/jenkins-values.yml")}"
  ]
}

# https://blog.devops.dev/jenkins-configuration-as-code-alternative-approach-981bc302d862
resource "kubernetes_config_map" "jcasc_jobs" {
  metadata {
    name = "jcasc-jobs"
    labels = {
      jenkins-jenkins-config = "true"
    }
    namespace = var.service_name
  }

  data = {
    "jcasc-jobs.yaml" = file("templates/jobs.yml")
  }
}

resource "kubernetes_config_map" "jcasc_kubernetes_config" {
  metadata {
    name = "jcasc-kubernetes-config"
    labels = {
      jenkins-jenkins-config = "true"
    }
    namespace = var.service_name
  }

  data = {
    "jcasc-kubernetes-config.yaml" = file("templates/kubernetes-config.yml")
  }
}