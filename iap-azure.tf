resource "google_firebase_project" "default" {
  provider = google-beta
  project  = local.project.id

  depends_on = [google_project_service.apis]
}

module "gcp_azure_iap" {
  source    = "git@github.com:KaveTech/tf-gcp-azure-iap.git?ref=v0.3"
  base_name = "spfld-docs"
  region    = local.region
  project = {
    id     = local.project.id
    number = local.project.number
  }
  bs_config = {
    backend_group = google_compute_region_network_endpoint_group.docs.id
  }
  oidc_config = {
    client_id     = data.sops_file.azure_oidc.data["client-id"]
    client_secret = data.sops_file.azure_oidc.data["client-secret"]
  }

  depends_on = [
    google_firebase_project.default,
    google_project_service.apis
  ]
}
