resource "google_kms_key_ring" "sops" {
  name     = format("%s-sops-keyring", local.base_name)
  project  = local.project.id
  location = local.region
}

resource "google_kms_crypto_key" "sops" {
  name     = format("%s-sops-key", local.base_name)
  key_ring = google_kms_key_ring.sops.id  ## google_kms_key_ring.sops[0].id

  purpose = "ENCRYPT_DECRYPT"

  lifecycle {
    prevent_destroy = true
  }

  rotation_period = "2592000s"

  version_template {
    algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
    protection_level = "SOFTWARE"
  }
}

resource "google_kms_crypto_key_iam_binding" "sops" {
  crypto_key_id = google_kms_crypto_key.sops.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  members = [
    "group:gcp-devops@kavehome.com",
  ]
}