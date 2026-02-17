module "state_bucket" {
  ## If the project has more than one workspace, uncomment this line
  ## count = terraform.workspace == "default" ? 1 : 0

  source = "git@github.com:KaveTech/tf-gcp-state-bucket.git"

  base-name = local.base_name

  members = [
    {
      member = "group:gcp-devops@kavehome.com"
      role   = "roles/storage.objectAdmin"
    }
  ]
}