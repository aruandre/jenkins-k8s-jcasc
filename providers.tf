terraform {
  required_version = "~> 1.5.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11.0"
    }
  }
}

provider "kubernetes" {
  config_path    = var.kube_config
  config_context = "minikube"
}

provider "helm" {
  kubernetes {
    config_path = var.kube_config
  }
}