resource "google_storage_bucket_iam_member" "cloudrun_reader" {
  bucket = google_storage_bucket.docs.name
  role   = "roles/storage.admin"
  member = format("serviceAccount:%s", google_service_account.cloudrun.email)
}

resource "google_storage_bucket_iam_member" "cloudrun_config_reader" {
  bucket = google_storage_bucket.caddy_config.name
  role   = "roles/storage.admin"
  member = format("serviceAccount:%s", google_service_account.cloudrun.email)
}