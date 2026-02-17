resource "google_project_service" "apis" {
  for_each = toset([
    # Most common APIs
    # "vpcaccess.googleapis.com",
    # "compute.googleapis.com",
    # "servicenetworking.googleapis.com",
    # "iam.googleapis.com",
    # "logging.googleapis.com",
    # "monitoring.googleapis.com",
    # "servicemanagement.googleapis.com",
    # "servicecontrol.googleapis.com",
    # "secretmanager.googleapis.com",
    # "container.googleapis.com",
    # "sqladmin.googleapis.com",
    # "cloudkms.googleapis.com",
    # "run.googleapis.com",
    #"cloudfunctions.googleapis.com",
    #"cloudbuild.googleapis.com",
    #"cloudscheduler.googleapis.com",
    #"cloudtasks.googleapis.com"
  ])
  service            = each.value
  project            = local.project.id
  disable_on_destroy = true
}