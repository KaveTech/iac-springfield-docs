resource "google_storage_bucket_iam_member" "github_actions_writer" {
  bucket = google_storage_bucket.docs.name
  role   = "roles/storage.objectAdmin"
  member = format("serviceAccount:%s", google_service_account.github_actions.email)
}
