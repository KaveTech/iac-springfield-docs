data "sops_file" "cloudflare_api_token" {
  source_file = "files/secrets/cloudflare.yaml"
}

data "sops_file" "azure_oidc" {
  source_file = "files/secrets/azure_oidc.yaml"
}

provider "cloudflare" {
  api_token = data.sops_file.cloudflare_api_token.data["api-token"]
}

provider "google" {
  user_project_override = true
}

provider "google-beta" {
  user_project_override = true
}