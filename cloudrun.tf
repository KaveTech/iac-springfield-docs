resource "google_service_account" "cloudrun" {
  project      = local.project.id
  account_id   = format("%s-run", local.base_name)
  display_name = "Cloud Run Docs Service Account"

  depends_on = [google_project_service.apis]
}

resource "google_cloud_run_v2_service" "docs" {
  name     = format("%s-server", local.base_name)
  project  = local.project.id
  location = local.region

  ingress = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  template {
    service_account       = google_service_account.cloudrun.email

    volumes {
      name = "docs"
      gcs {
        bucket    = google_storage_bucket.docs.name
        read_only = true
      }
    }

    containers {
      image = "nginx:stable-alpine"

      volume_mounts {
        name       = "docs"
        mount_path = "/usr/share/nginx/html"
      }

      ports {
        container_port = 80
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }
    }

    scaling {
      min_instance_count = 0
      max_instance_count = 2
    }
  }

  depends_on = [google_project_service.apis]
}
