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

    volumes {
      name = "config"
      gcs {
        bucket    = google_storage_bucket.caddy_config.name
        read_only = true
      }
    }

    containers {
      image = "caddy:alpine"

      volume_mounts {
        name       = "docs"
        mount_path = "/app/docs"
      }

      volume_mounts {
        name       = "config"
        mount_path = "/etc/caddy"
      }

      ports {
        container_port = 8080
      }

      command = [
        "caddy",
        "run",
        "--config",
        "/etc/caddy/Caddyfile",
        "--adapter",
        "caddyfile"
      ]

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
