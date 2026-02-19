output "state_bucket_name" {
  value = try(module.state_bucket.state-bucket-name, "")
}

output "project_id" {
  value = try(google_project.project.project_id, "")
}

output "project_number" {
  value = try(google_project.project.number, "")
}

output "docs_bucket_name" {
  value = google_storage_bucket.docs.name
}

output "docs_url" {
  value = format("https://%s", local.domain)
}

output "lb_ip_address" {
  value = google_compute_global_address.docs.address
}

output "github_actions_sa_email" {
  value = google_service_account.github_actions.email
}

output "github_actions_sa_key" {
  value     = google_service_account_key.github_actions.private_key
  sensitive = true
}

output "kms_key_id" {
  value = google_kms_crypto_key.sops.id
}