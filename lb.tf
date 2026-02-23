resource "google_compute_global_address" "docs" {
  name    = format("%s-lb-ip", local.base_name)
  project = local.project.id

  depends_on = [google_project_service.apis]
}

resource "google_compute_managed_ssl_certificate" "docs" {
  name    = format("%s-ssl-cert", local.base_name)
  project = local.project.id

  managed {
    domains = [local.domain]
  }
}

resource "google_compute_region_network_endpoint_group" "docs" {
  name                  = format("%s-neg", local.base_name)
  project               = local.project.id
  region                = local.region
  network_endpoint_type = "SERVERLESS"

  cloud_run {
    service = google_cloud_run_v2_service.docs.name
  }
}

resource "google_compute_url_map" "docs" {
  name            = format("%s-url-map", local.base_name)
  project         = local.project.id
  default_service = module.gcp_azure_iap.backend_service_id
}

resource "google_compute_target_https_proxy" "docs" {
  name             = format("%s-https-proxy", local.base_name)
  project          = local.project.id
  url_map          = google_compute_url_map.docs.id
  ssl_certificates = [google_compute_managed_ssl_certificate.docs.id]
}

resource "google_compute_global_forwarding_rule" "docs_https" {
  name                  = format("%s-https-fwd-rule", local.base_name)
  project               = local.project.id
  load_balancing_scheme = "EXTERNAL_MANAGED"
  target                = google_compute_target_https_proxy.docs.id
  ip_address            = google_compute_global_address.docs.address
  port_range            = "443"
}

resource "google_compute_url_map" "https_redirect" {
  name    = format("%s-https-redirect", local.base_name)
  project = local.project.id

  default_url_redirect {
    https_redirect         = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
  }
}

resource "google_compute_target_http_proxy" "https_redirect" {
  name    = format("%s-http-proxy", local.base_name)
  project = local.project.id
  url_map = google_compute_url_map.https_redirect.id
}

resource "google_compute_global_forwarding_rule" "docs_http" {
  name                  = format("%s-http-fwd-rule", local.base_name)
  project               = local.project.id
  load_balancing_scheme = "EXTERNAL_MANAGED"
  target                = google_compute_target_http_proxy.https_redirect.id
  ip_address            = google_compute_global_address.docs.address
  port_range            = "80"
}
