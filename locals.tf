locals {
  base_name      = ""
  pretty_name    = ""
  project = {
    id = google_project.project.project_id #google_project.project[0].project_id
    number = google_project.project.number #google_project.project[0].number
  }
  region = "europe-west1"
}