provider "grafana" {
  url  = module.gcl_to_grafana.grafana_url
  auth = module.gcl_to_grafana.grafana_sa_token
}