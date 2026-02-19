resource "google_service_account" "github_actions" {
  project      = local.project.id
  account_id   = format("%s-gh-actions", local.base_name)
  display_name = "GitHub Actions - Docs Upload"

  depends_on = [google_project_service.apis]
}

resource "google_service_account_key" "github_actions" {
  service_account_id = google_service_account.github_actions.name
}
