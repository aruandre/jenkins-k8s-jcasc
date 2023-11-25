terraform {
  required_version = "~> 1.5"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
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