# You will need this most of the time to encrypt and decrypt secrets, delete it if you don't need it.
resource "google_kms_key_ring" "sops" {
  ## If the project has more than one workspace, uncomment this line
  ## count = terraform.workspace == "default" ? 1 : 0
  name     = format("%s-sops-keyring", local.base_name)
  project  = local.project.id
  location = local.region
}

resource "google_kms_crypto_key" "sops" {
  ## If the project has more than one workspace, uncomment this line
  ## count = terraform.workspace == "default" ? 1 : 0
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
  ## If the project has more than one workspace, uncomment this line
  ## count = terraform.workspace == "default" ? 1 : 0
  crypto_key_id = google_kms_crypto_key.sops.id ## google_kms_key_ring.sops[0].id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  members = [
    "group:gcp-devops@kavehome.com",
  ]
}

# Example of how to use sops to encrypt and decrypt secrets
# data "sops_file" "secret" {
#   input_file = "secrets.yaml"
# }
# 
# output "secret" {
#   value = data.sops_file.secret.data["secret"]
# }
