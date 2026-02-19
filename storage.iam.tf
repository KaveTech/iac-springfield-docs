resource "google_storage_bucket_iam_member" "cloudrun_reader" {
  bucket = google_storage_bucket.docs.name
  role   = "roles/storage.objectViewer"
  member = format("serviceAccount:%s", google_service_account.cloudrun.email)
}
