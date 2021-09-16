provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = "/var/secrets/google/ec-service-account-config.json"
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
  credentials = "/var/secrets/google/ec-service-account-config.json"
}