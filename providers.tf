data "sops_file" "cloudflare_api_token" {
  source_file = "files/secrets/cloudflare.yaml"
}

provider "cloudflare" {
  api_token = data.sops_file.cloudflare_api_token.data["api-token"]
}