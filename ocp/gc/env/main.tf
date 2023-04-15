terraform {
  required_version = "~> 1.4.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.61.0"
    }
  }
  backend "local" {}
}

locals {
  project_name     = "test"
  application_name = "rds-snapshot-exporter"
  project_id       = var.project_id
  region           = var.region
}

provider "google" {
  credentials = file("./creds.json")
  project     = local.project_id
  region      = local.region
}

module "main" {
  source = "../main"

  project_region   = local.region
  project_name     = local.project_name
  application_name = local.application_name
}
