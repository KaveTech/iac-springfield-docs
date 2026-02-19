resource "google_storage_bucket" "docs" {
  name     = format("%s-%s", local.base_name, local.project.id)
  project  = local.project.id
  location = local.region

  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }

  force_destroy = false

  depends_on = [google_project_service.apis]
}
