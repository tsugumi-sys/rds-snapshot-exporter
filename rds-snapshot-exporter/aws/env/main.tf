terraform {
  required_version = "~> 1.4.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.62.0"
    }
  }
  backend "local" {}
}

locals {
  project_name     = "test"
  application_name = "rds-snapshot-exporter"
  s3 = {
    lifecycle = {
      status          = "Enabled"
      expiration_days = 30
    }
  }
  region = ""
}

provider "aws" {
  region = var.region
}


module "main" {
  source           = "../main"
  project_name     = local.project_name
  application_name = local.application_name
  s3               = local.s3
}
