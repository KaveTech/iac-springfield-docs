module "cloudflare_dns" {
  source = "git@github.com:KaveTech/tf-cloudflare-dns-record.git?ref=v0.3"

  project = {
    id     = local.project.id
    number = local.project.number
  }

  zone_id = "73e426c839b17b67d87569c61985a55d"

  dns_records = {
    "springfield-docs" = {
      type    = "A"
      content = google_compute_global_address.docs.address
      ttl     = 3600
    }
  }
}