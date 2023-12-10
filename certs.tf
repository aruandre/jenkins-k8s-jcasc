resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "tls_self_signed_cert" "cert" {
  private_key_pem = tls_private_key.key.private_key_pem

  subject {
    common_name  = "andre.home"
    organization = "My home, Inc"
  }

  validity_period_hours = 720

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "local_file" "key" {
  content  = tls_private_key.key.private_key_pem_pkcs8
  filename = "${path.module}/certs/key.pem"
}

resource "local_file" "cert" {
  content  = tls_self_signed_cert.cert.cert_pem
  filename = "${path.module}/certs/cert.pem"
}