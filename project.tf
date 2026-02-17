resource "random_string" "project_id" {
  length  = 4
  special = false
  upper   = false
}

resource "google_folder" "folder" {
  display_name = local.pretty_name
  parent       = "folders/122179877233" # Kave Tech/Internal Folder ID, fill with your own folder id.
}

# If the project has only one workspace, you can use the following block

resource "google_project" "project" {
  project_id      = format("%s-%s-%s", local.base_name, lower(replace(replace(terraform.workspace, "_", "-"), "default", "pro")), random_string.project_id.result)
  name            = format("%s-%s", local.base_name, lower(replace(replace(terraform.workspace, "_", "-"), "default", "pro")))
  folder_id       = google_folder.folder.id
  deletion_policy = "PREVENT"
  billing_account = "0158E1-56DA57-C3303B" ## MakingScience Billing Account ID, normally you will allways use this.

  labels = {
    "managed-by"  = "terraform"
    "region"      = local.region
    "environment" = lower(replace(replace(terraform.workspace, "_", "-"), "default", "sys"))
  }
}

# If the project has more than one workspace, you can use the following block

# resource "google_project" "project" {
#   project_id      = format("%s-%s-%s", local.base_name, lower(replace(replace(terraform.workspace, "_", "-"), "default", "sys")), random_string.project_id.result)
#   name            = format("%s-%s", local.base_name, lower(replace(replace(terraform.workspace, "_", "-"), "default", "sys")))
#   folder_id       = google_folder.folder.id
#   deletion_policy = "PREVENT"
#   billing_account = "0158E1-56DA57-C3303B" ## MakingScience Billing Account ID, normally you will allways use this.
# 
#   labels = {
#     "managed-by"  = "terraform"
#     "region"      = local.region
#     "environment" = lower(replace(replace(terraform.workspace, "_", "-"), "default", "sys"))
#   }
# }
