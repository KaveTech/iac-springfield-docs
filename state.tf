module "state_bucket" {
  source = "git@github.com:KaveTech/tf-gcp-state-bucket.git"

  base-name = local.base_name

  members = [
    {
      member = "group:gcp-devops@kavehome.com"
      role   = "roles/storage.objectAdmin"
    }
  ]
}
