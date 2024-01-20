resource "kubernetes_namespace" "vault" {
  metadata {
    name = var.vault_namespace
  }
}

resource "helm_release" "vault" {
  name       = kubernetes_namespace.vault.id
  repository = "https://helm.releases.hashicorp.com/"
  chart      = kubernetes_namespace.vault.id
  version    = var.vault_chart_version
  namespace  = kubernetes_namespace.vault.id
  values = [
    templatefile("${path.root}/templates/vault/vault.tmpl", {
        nodePort = var.vault_nodePort
    })
  ]
}

resource "tls_private_key" "ed25519-example" {
  algorithm = "ED25519"
}

resource "tls_self_signed_cert" "example" {
  private_key_pem = tls_private_key.ed25519-example.private_key_pem

  subject {
    common_name  = "andre.com"
    organization = "MyHome, Inc"
  }

  validity_period_hours = 365

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "data_encipherment"
  ]
}

resource "local_file" "key" {
  content = tls_private_key.ed25519-example.private_key_pem
  filename = "certs/vault.key"
}

resource "local_file" "cert" {
  content = tls_self_signed_cert.example.cert_pem
  filename = "certs/vault.crt"
}