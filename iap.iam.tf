resource "google_iap_web_backend_service_iam_member" "docs" {
  project             = local.project.id
  web_backend_service = google_compute_backend_service.docs.name
  role                = "roles/iap.httpsResourceAccessor"
  member              = "domain:kavehome.com"
}
