locals {
  base_name   = "springfield-docs"
  pretty_name = "Springfield Docs"
  project = {
    id     = google_project.project.project_id
    number = google_project.project.number
  }
  region = "europe-west1"
  domain = "springfield-docs.kave.tech"
}
