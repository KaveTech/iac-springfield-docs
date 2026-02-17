terraform {
  required_version = ">= 1.5.0"

  # Once the state bucket is created, you can use the following block
  # backend "gcs" {
  #   bucket = ""
  #   prefix = "tfstate"
  # }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.5.0" # Update to the latest version of the provider https://registry.terraform.io/providers/hashicorp/google/latest
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "7.5.0" # the same as the google provider
    }
    sops = {
      source  = "carlpett/sops"
      version = "1.3.0"
    }
    grafana = {
      source  = "grafana/grafana"
      version = "4.21.0"
    }
  }
}