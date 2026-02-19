terraform {
  required_version = ">= 1.5.0"

  backend "gcs" {
    bucket = "springfield-docs-state-22eb01d9"
    prefix = "tfstate"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "7.5.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.11.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 1.2.0"
    }
  }
}
