resource "google_project_service" "apis" {
  for_each = toset([
    "compute.googleapis.com",
    "run.googleapis.com",
    "iap.googleapis.com",
    "iam.googleapis.com",
    "storage.googleapis.com",
    "cloudkms.googleapis.com",
    "identitytoolkit.googleapis.com",
    "firebase.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "apikeys.googleapis.com",
    "serviceusage.googleapis.com"
  ])
  service            = each.value
  project            = local.project.id
  disable_on_destroy = true
}
