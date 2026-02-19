resource "google_project_service_identity" "iap" {
  provider = google-beta
  project  = local.project.id
  service  = "iap.googleapis.com"
}


resource "google_cloud_run_v2_service_iam_member" "iap_invoker" {
  project  = google_cloud_run_v2_service.docs.project
  location = google_cloud_run_v2_service.docs.location
  name     = google_cloud_run_v2_service.docs.name
  role     = "roles/run.invoker"
  member   = format("serviceAccount:%s", google_project_service_identity.iap.email)
}
